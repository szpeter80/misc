**Generate KEY for cert**

```openssl genrsa -out server.key 2048```

**Generate CSR with SAN**

```
openssl req -new -key server.key -out server.csr \
    -subj "/C=US/ST=Krakosia/L=City/O=ACME corp/CN=*.apps.kube.example.com" \
    -addext "subjectAltName=DNS:*.apps.kube.example.com,IP:192.168.1.1"
 ```
 Verify with:  
 ```
 openssl req -noout -text -in server.csr
 ```
 
 **Self-sign CSR to provide CRT**

```
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
 ```
 Verify with:  
 ```
 openssl x509 -noout -text -in server.crt
 ```
 
 **Convert from Microsoft binary CER -> PEM (base64 encoded text)**

```
openssl x509 -in microsoft.cer -out ./pemformat.crt -outform pem
```

**Convert Microsoft binary PFX bundle to PEM**

Extract the certificate without password:  
```openssl pkcs12 -in microsoft.pfx  -nokeys -out myserver.crt -nodes```

Extract the private key (with password):  
```openssl pkcs12 -in certname.pfx -nocerts -out myserver.key```

Remove password from private key:  
```openssl rsa -in myserver.key -out myserver_unencrypted.key```

