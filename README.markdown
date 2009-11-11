Apns4r
======

This lib is intended to allow write my own APNs provider for Apple Push
Notificaion services (APNs) in ruby.  Requires json gem.

Can be used as Rails plugin too. No models and rake tasks, just pick sample
config and fire-and-forget this notifications.

Installation
============
Use git, Luke!
For Rails:

    ./script/plugin install git://github.com/thegeekbird/Apns4r.git

and for the rest world `git submodule` can be a solution:

    git submodule add git://github.com/thegeekbird/Apns4r.git vendor/Apns4r

Configuration
=============

If you want to use APNs sertificates with ruby (ie with OpenSSL),
here's a tip from [great post about integration between Python and APNs](http://blog.nuclearbunny.org/2009/05/11/connecting-to-apple-push-notification-services-using-python-twisted/):

>One caveat  - the Mac OS X Keychain Access application does not directly export
>certificates and private keys in Private Enhanced Mail (.pem)  format, which is
>what the OpenSSL implementation we use with Twisted will want, but luckily
>there’s an easy mechanism to convert if you export the files as Personal
>Information Exchange (.p12) format. The following two commands can be used to
>convert the .p12 files into .pem files using the built-in openssl command on
>Mac OS X or most Linux distributions:
    openssl pkcs12 -in cred.p12 -out certkey.pem -nodes -clcerts
    openssl pcks12 -in pkey.p12 -out pkey.pem -nodes -clcerts

For code samples see Example section, also there is simple EventMachine powered
sendserver.rb and two config samples.

Example
=======

All simple as require - create Notification - push, just try it in irb

    require 'lib/apns4r' #=> true
    n = APNs4r::Notification.create 'e754dXXX', { :aps => {:alert => "Hey, dude!", :badge => 1}, :custom_data => "asd" } #=> #<APNs4r::Notification:0x11fe2c0>
    APNs4r::Sender.new.push n #=> 97

Doc
===
[Gimme moar guts](http://rdoc.info/projects/thegeekbird/Apns4r)

Copyright (c) 2009 Leonid Ponomarev, released under the MIT license
