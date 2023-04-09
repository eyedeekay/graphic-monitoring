I2PControl for Lua and Conky-Lua
================================

Usage:

First, enable i2pcontrol on your I2P router by going to [Web App Configuration](http://127.0.0.1:7657/configwebapps) and starting the `jsonrpc` app.
The `i2pcontrol.lua` expects the password to be `itoopie`, which is the default.
Once you have done so, execute the following commands to test them:

```sh
git clone --recursive https://github.com/eyedeekay/graphic-monitoring
cd graphic-monitoring
conky -c _dot_conkyrc
```

![screenshot.png](screenshot.png)

Other ways of setting it up:
----------------------------

```sh
# from this directory(a checkout)
conky -c _dot_conkyrc
```

```sh
# installation to $HOME/.conkyrc
mkdir -p $HOME/lua
cp -rv lua/* $HOME/lua/
cp -v _dot_conkyrc $HOME/.conkyrc
```

```sh
# usage with i2pd
export I2P_CONTROL="http://127.0.0.1:7650"
conky -c _dot_conkyrc
```

![screenshot-2.png](screenshot-2.png)