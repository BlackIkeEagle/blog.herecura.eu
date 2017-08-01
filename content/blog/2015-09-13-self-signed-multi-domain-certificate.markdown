---
title: "Self signed multi-domain certificate"
date: "2015-09-13"
categories:
    - "webdevelopment"
    - "Linux"
    - "OSx"
tags:
    - "openssl"
    - "Linux"
    - "OSx"
    - "macOS"
---

When you are developing a complex website with multiple subdomains and full
https, it can be hard to mimic it in your development environment. For this
purpose we will create a CA we will trust for development and that will allow
us to generate multi-domain ssl keys.

<!--more-->

## Create a Root CA

Generate a key for your Root CA

~~~
$ openssl genrsa 8192 > HerecuraCA.key 
~~~

Generate your root certificate

~~~
$ openssl req -x509 -new -nodes -key HerecuraCA.key -days 3650 > HerecuraCA.pem
~~~

Enter your root certificate information

~~~
Country Name (2 letter code) [AU]:BE
State or Province Name (full name) [Some-State]:West-Vlaanderen
Locality Name (eg, city) []:Brugge
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Herecura
Organizational Unit Name (eg, section) []:Development
Common Name (e.g. server FQDN or YOUR name) []:Herecura CA
Email Address []:ike.devolder@gmail.com
~~~

Import this HerecuraCA.pem file in your browser.

## Generating a multidomain certificate

Again we want to create a certificate that lasts for a very long time :).

create the key:

~~~
openssl genrsa 4096 > example.dev.key
~~~

Now instead of generating a wildcard certificate we create a CSR (certificate
signing request)

~~~
openssl req -new -key example.dev.key > example.dev.csr
~~~

Enter the following:

~~~
Country Name (2 letter code) [AU]:BE
State or Province Name (full name) [Some-State]:West-Vlaanderen
Locality Name (eg, city) []:Brugge
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Herecura
Organizational Unit Name (eg, section) []:Development
Common Name (e.g. server FQDN or YOUR name) []:example.dev
Email Address []:ike.devolder@gmail.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
~~~

When we have created the CSR we need to create a config file with the desired
domains

We create the file example.dev.extensions:

~~~
[ example_dev ]
nsCertType              = server
keyUsage                = digitalSignature,nonRepudiation,keyEncipherment
extendedKeyUsage        = serverAuth
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid,issuer
subjectAltName          = @example_dev_subject
[ example_dev_subject ]
DNS.1 = example.dev
DNS.2 = www.example.dev
DNS.3 = cdn.example.dev
DNS.4 = nl-be.example.dev
DNS.5 = fr-be.example.dev
DNS.6 = de-be.example.dev
~~~

With all our domains listed we can generate the certificate now

~~~
openssl x509 -req -days 3600 -CA HerecuraCA.pem -CAkey HerecuraCA.key -CAcreateserial -in example.dev.csr -extfile example.dev.extensions -extensions example_dev > example.dev.pem
~~~

Now we have a multidomain self signed certificate.

## Generating the information of the certificate

To generate the information in the certificate run:

~~~
openssl x509 -noout -fingerprint -text < example.dev.pem > example.dev.info
~~~

## Tips

### Use the certificate in your apache config

~~~
# -*- mode: apache -*-
# vi: set ft=apache :
<VirtualHost *:443>
	ServerAdmin ike.devolder@gmail.com

	ServerName example.dev

    ServerAlias www.example.dev
    ServerAlias cdn.example.dev
    ServerAlias nl-be.example.dev
    ServerAlias fr-be.example.dev
    ServerAlias de-be.example.dev

	DocumentRoot /var/www/example.dev/public

	SSLEngine on
	SSLCertificateFile /etc/ssl/example.dev.pem
	SSLCertificateKeyFile /etc/ssl/example.dev.key

	<Directory /var/www/example.dev/public/>
		Options Indexes FollowSymLinks
		AllowOverride None

		Require all granted
	</Directory>

</VirtualHost>
~~~

### Add certificate to chrome based browsers

* goto your chrome settings
* advanced
* Manage Certificates

![Manage Certificates](/blog/2015-09-13-self-signed-multi-domain-certificate/chrome-01-manage-certificates.png)

* Authorities

![Authorities](/blog/2015-09-13-self-signed-multi-domain-certificate/chrome-02-certificate-manager.png)

* Import HerecuraCA.pem

![Load herecuraCA](/blog/2015-09-13-self-signed-multi-domain-certificate/chrome-03-load-herecuraCA.png)

* Select what this certificate will be trusted for

![Select trust](/blog/2015-09-13-self-signed-multi-domain-certificate/chrome-04-select-trust.png)

* See it's there in the list

![verify](/blog/2015-09-13-self-signed-multi-domain-certificate/chrome-05-verify.png)

Now we no longer have to worry about the annoying messages and can use https in
development without a hassle.

### Add certificate to firefox

* goto preferences
* advanced
* click certificates tab

![Select trust](/blog/2015-09-13-self-signed-multi-domain-certificate/firefox-01-advanced-certificates.png)

* view certificates / authorities

![Select trust](/blog/2015-09-13-self-signed-multi-domain-certificate/firefox-02-certificate-manager.png)

* Import HerecuraCA.pem

![Select trust](/blog/2015-09-13-self-signed-multi-domain-certificate/firefox-03-select-herecuraCA.png)

* Select what this certificate will be trusted for

![Select trust](/blog/2015-09-13-self-signed-multi-domain-certificate/firefox-04-select-trust.png)

* and we can see it in the list

![Select trust](/blog/2015-09-13-self-signed-multi-domain-certificate/firefox-05-verify.png)

### Add certificate to OS X

OS X does not support 8192 certificates by default so first you'll have to
enable that:

~~~
sudo defaults write /Library/Preferences/com.apple.security RSAMaxKeySize -int 8192
~~~

Then import the Herecura Certificate Authority to enable the example.dev
certificates:

~~~
sudo /usr/bin/security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain HerecuraCA.pem
~~~

![OS X import](/blog/2015-09-13-self-signed-multi-domain-certificate/osx-01-add-to-keychain.png)

And verify everything worked:

![OS X verify](/blog/2015-09-13-self-signed-multi-domain-certificate/osx-02-verify.png)
