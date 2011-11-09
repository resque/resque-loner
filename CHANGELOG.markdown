1.1.0
--------------------------------
Merged in @ryansch's pull requests to clean up things a bit.
This removed the `enqueue_to` and `dequeue_from` methods from
resque-loner because it caused troubles with resque's own 
`enqueue_to`.

1.0.1
--------------------------------
Pulled in #8 and #9 so that removing empty queues
does not fail

1.0
---------------------------------
