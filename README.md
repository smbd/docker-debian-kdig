# 最新のkdig in Debian stable

最新(Debian sid)のkdigをDebian stableでbuildしたimage

## usage
```
docker run --rm smbd/kdig +json +dnssec -t AAAA www.google.com
```

## build
./build.sh
