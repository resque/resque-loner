Resque-Loner
======

[![Build Status](https://secure.travis-ci.org/resque/resque-loner.png?branch=master)](https://travis-ci.org/resque/resque-loner)
[![Code Climate](https://codeclimate.com/github/resque/resque-loner.png)](https://codeclimate.com/github/resque/resque-loner)
[![Gem Version](https://badge.fury.io/rb/resque-loner.png)](http://badge.fury.io/rb/resque-loner)

Resque-Loner is a plugin for defunkt/resque which adds unique jobs to resque: Only one job with the same payload per queue.


Installation
-------------

First install the gem:

    $ gem install resque-loner 

Then include it in your app:

    require 'resque-loner'


Tests
-----------
To make sure this plugin works on your installation, you should run the tests. resque-loner is tested in RSpec, but it also includes resque's original testsuite. You can run all tests specific to resque-loner with `rake spec`.

To make sure the plugin did not break resque, you can run `rake test` (the standard resque test suite). This runs all tests from the 1.22.0 version of resque, so make sure you have that version of resque installed, when you run the resque-tests.

Example
--------

Unique jobs can be useful in situations where running the same job multiple times issues the same results. Let's say you have a job called CacheSweeper that refreshes some cache. A user has edited some_article, so you put a job on the queue to refresh the cache for that article.

    >> Resque.enqueue CacheSweeper, some_article.id
    => "OK"

Your queue is really full, so the job does not get executed right away. But the user editing the article has noticed another error, and updates the article again, and your app kindly queues another job to update that article's cache.

    >> Resque.enqueue CacheSweeper, some_article.id
    => "OK"

At this point you will have two jobs in the queue, the second of which has no effect: You don't have to run it, once the cache has been updated for the first time. This is where resque-loner's UniqueJobs come in. If you define CacheSweeper like this:

    class CacheSweeper
      include Resque::Plugins::UniqueJob
      @queue = :cache_sweeps

      def self.perform(article_id)
        # Cache Me If You Can...
      end
    end

Just like that you've assured that on the :cache_sweeps queue, there can only be one CacheSweeper job for each article. Let's see what happens when you try to enqueue a couple of these jobs now:

    >> Resque.enqueue CacheSweeper, 1
    => "OK"
    >> Resque.enqueue CacheSweeper, 1
    => "EXISTED"
    >> Resque.enqueue CacheSweeper, 1
    => "EXISTED"
    >> Resque.size :cache_sweeps
    => 1

Since resque-loner keeps track of which jobs are queued in a way that allows for finding jobs very quickly, you can also query if a job is currently in a queue:

    >> Resque.enqueue CacheSweeper, 1
    => "OK"
    >> Resque.enqueued? CacheSweeper, 1
    => true
    >> Resque.enqueued? CacheSweeper, 2
    => false
    >> Resque.enqueued_in? :another_queue, CacheSweeper, 1
    => false

How it works
--------

### Keeping track of queued unique jobs

For each created UniqueJob, resque-loner sets a redis key to 1. This key remains set until the job has either been fetched from the queue or destroyed through the Resque::Job.destroy method. As long as the key is set, the job is considered queued and consequent queue adds are being rejected.

Here's how these keys are constructed:

    resque:loners:queue:cache_sweeps:job:5ac5a005253450606aa9bc3b3d52ea5b
    |          |        |                |
    |          |        |                `---- Job's ID (#redis_key method)
    |          |        `--------------------- Name of the queue
    |          `------------------------------ Prefix for this plugin
    `----------------------------------------- Your redis namespace

The last part of this key is the job's ID, which is pretty much your queue item's payload. For our CacheSweeper job, the payload would be:

    { 'class': 'CacheSweeper', 'args': [1] }`

The default method to create a job ID from these parameters  is to do some normalization on the payload and then md5'ing it (defined in `Resque::Plugins::UniqueJob#redis_key`).

You could also use the whole payload or anything else as a redis key, as long as you make sure these requirements are met:

1. Two jobs of the same class with the same parameters/arguments/workload must produce the same redis_key
2. Two jobs with either a different class or different parameters/arguments/workloads must not produce the same redis key 
3. The key must not be binary, because this restriction applies to redis keys: *Keys are not binary safe strings in Redis, but just strings not containing a space or a newline character. For instance "foo" or "123456789" or "foo_bar" are valid keys, while "hello world" or "hello\n" are not.* (see http://code.google.com/p/redis/wiki/IntroductionToRedisDataTypes)

So when your job overwrites the #redis_key method, make sure these requirements are met. And all should be good.

### Resque integration

Unfortunately not everything could be done as a plugin, so I overwrote three methods of Resque::Job: create, reserve and destroy (I found no hooks for these events). All the logic is in `module Resque::Plugins::Loner` though, so it should be fairly easy to make this a *pure* plugin once the hooks are known.
