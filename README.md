# restarter

## What It Does

This was built with Kubernetes in mind but works fine with standalone Docker. Sometimes you just want to copy a change into a running container without rebuilding the image, pushing it to the image registry, then killing pods.

## How It Works

restarter listens for the `HUP` signal. If received, it restarts the application. restarter does not modify the exit code of the application. And it will correctly propagate the `TERM` signal to the application.

## Benefits

* No major changes to how you invoke your app.
* One-time image update. Can leave restarter in image and just change command line after you're done using it.

## To Do

* Could be a static binary. For now bash.
* If the container exits on its own, all changes will be lost. If you suddenly see the old version running, check the previous log for why it exited.

## Building the Example

```console
$ docker build -t example.com/myrepo/restarter-test:latest .
$ docker push example.com/myrepo/restarter-test:latest
```

## Using the Example

```console
$ kubectl create -f pod.yaml
$ kubectl logs restarter-test  # show app started successfully
$ kubectl cp test-app-v2 restarter-test:/test-app  # copy new binary
$ kubectl exec restarter-test -- kill -HUP 1  # tell restarter to restart the app
$ kubectl logs restarter-test  # show that app has been restarted with new binary
```

## Using for Real

In the simplest case, `bash` already exists in your app's image and you can just create a `Dockerfile` like so that adds restarter:

```Dockerfile
FROM example.com/myrepo/myapp:latest
ADD restarter /restarter
```

Then modify the Kubernetes spec to change:

* Image should be the one you build and push above (the one that has `restarter` added).
* Prefix your existing command line with `/restarter`.
