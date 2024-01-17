# kdig in Debian stable

kdigをDebian stableでbuildしたimage

## usage
```
docker run --rm smbd/kdig +json +dnssec -t AAAA www.google.com
```

## build
./build.sh
