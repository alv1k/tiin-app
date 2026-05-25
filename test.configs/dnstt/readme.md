

# for app:

```
socks://#name -> dnstt://?tunnel_per_resolver=4&resolver=8.8.8.8:53&resolver=8.8.4.4:53&domain=dnstt.tiin_vpn.com&publicKey=xxxx
```
or

```
{
  "outbounds": [
    {
      "type": "socks",
      "tag": "socks",
      "version": "5",
      "detour": "dnstt1В§hideВ§"
    },
    {
      "type": "dnstt",
      "tag": "dnstt1В§hideВ§",
      "publicKey": "xxxx",
      "domain": "dnstt.tiin_vpn.com",
      "tunnel_per_resolver": 4,
      "resolvers": ["8.8.8.8:53", "8.8.4.4:53"]
    }
  ]
}
```



# For cli or router or relay server:
download tiin_vpn core from:
https://github.com/tiin_vpn/tiin_vpn-core/releases/

then you can run dnstt in router or relay server via

```
tiin_vpn-core srun -c config.json
```

see: dnstt_raw_config.json
