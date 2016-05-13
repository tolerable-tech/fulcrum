# Fulcrum

This is an initial prototype of the future.  

## ROADMAP

* √ run app in fleet

* √ POC plugins
  * √ build a plugin using makefiles
  * √ start it on cluster with fleet
  * √ Elixir code to start it on cluster

* √ define a beginning of a plugin JSON descriptiong
  * √ not too detailed, we want a name, desc, status URL, maybe a snippet URL.

* √ elixir code to download plugins

* √ deploy on DO from cloud-config
  * √ start all the things
  * √ nginx requests SSL certs on boot after domain is resolvable
  * √ can survive a reboot
  * √ run DB setup (need a way to setup first user -- maybe a onetime token? a preset recovery hash?)

* √ NginxRegister app putting hostnames and IPs of instances in ETCD

* SSL config for nginx (maybe it reads the key from etcd, i have no idea if this is secure though so prbs not, encrypteverything cert?)
  * √ we have nginx looking for an app/<name>/ssl flag and turning it on
  * √ we are using a letsencrypt cert from a mounted volumn
  * √ this is pretty important, right now all our sign-ins are lame. once we have
      SSL rocking we should just stop listening on port 80 and only go SSL.
  * we need to provide a way for renewing the cert every 60 days
  * √ we need to provide components a way to add their domains to the cert

* Represent docker volumes and other artifacts that need to be handled seperately
  from the lifecycle of the component process (e.g. persist across start/stops)

* √ provide an accompaniment that will back up docker volumes to aws s3
  * √ `s3_accompaniment`, provide a `volumes` key in the configuration. will
      tar up the folder specified and upload to s3 every hour.

* AWS Lambda open source alternative.
  * container/s that run arbitrary code at a unique address.
  * or, do we just provide an interface for AWS lambda?

* elixir controller publishes a URL that plugins can use to send notifications
  * auth? only the private IP?
  * do plugins have to get permission to publish notifications?
  * TMI, for now, lets just publish them on home screen.

* a notification management plugin?

* where do plugins store data?
  * √ in the JSON, specify dependencies? i.e. redis, postgresql, elasticsearch?
  * do we share those resources, so we're only running one of each?
    * if a component is listed in `requirements` but not dependencies then we
      view it as a shared resource?
  * publish a URL in etcd that those plugins can use?

#NOTES

https://www.digitalocean.com/community/tutorials/how-to-enable-floating-ips-on-an-older-droplet

```
Copyright © 2016 Tolerable Technology

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

Please see LICENSE.txt for a full copy of the GNU General Public License.
```

