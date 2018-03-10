---
layout: post
published: true
mathjax: false
featured: true
comments: false
title: Ethereum Iota Hackathon
categories:
  - personal
  - Hackathon
  - DLT
  - Programming
tags: >-
  ethereum solidity bluetooth socket cpp python javascript bash raspberry hikey
  drone
---
## Summer 2017: Ethereum+Iota hackathon in Frankfurt

In May 2017 I read on the website of the blockchain department of the Technical University Munich that they are going to co-host a hackathon on DLT in Frankfurt.

Together with a friend we applied for the "grant program" because we weren't willing to pay 700 € for one week. When we were noticed about us being accepted we did not know what to expect from that week hosted by Frankfurt Business School.

**To be honest:** Both of us are not the kind of sales guys to be interested in the Frankfurt Business School. That is why we were skeptical.

![frankfurt_skyline.png]({{site.baseurl}}/images/frankfurt_skyline.png)

## Our prejudices vanished up in thin air

On the first official day of the Hackathon all of our skepticism was gone when we arrived at the event location called Tatcraft. It is a renovated factory in the suburban region of Frankfurt with an active Makers community providing tools like water-cutters, huge 3d printers etc.

<p>
  <figure>
    <div class="videoWrapper">
      <iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/ojwR1DwMBak?rel=0" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
    </div>
  </figure>
</p>

The weather was great, we formed teams for the hackathon, had nice chats, listened to speakers and had a lot of fun.

## The speakers

I don't remember too many of them. There were speakers from the Commerzbank DLT Lab and a department of Daimler working on Truck solutions (somehow we expected these because of the Frankfurt Business School). But there were also speakers from Eciotify which were really cool guys, BigchainDB and Iota.

You could also learn how to legally organize an ICO and other administrative stuff but we preferred to work on our prototype for the hackathon.

## The prototype

![Screenshot from 2018-03-05 13-15-46.png]({{site.baseurl}}/images/Screenshot from 2018-03-05 13-15-46.png)

With a team of six we took the challenge to build a self-managed drone charging system. You can find all about the concept in the following video of the final presentation:

<p>
  <figure>
    <div class="videoWrapper">
      <iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/44oTBKQfcjE?rel=0" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
    </div>
  </figure>
</p>

Even more details by a blockchain vlogger: [Youtube video](https://www.youtube.com/watch?v=p4nhJqEd1zY)

## The technical aspects

### Hardware

![drone.jpeg]({{site.baseurl}}/images/drone.jpeg)

- The Drone: We attached a raspberry pi 2 with a usb powerbank to a small quadrocopter. The powerbank powers the raspby and is also connected to an inductive charging card for cellphones. 
- The charging station is a box with a HiKey board (which was suggested by the guys from Eciotify) and an inductive charging station from Samsung. The charging station was controlled by a Relais to turn it on and off.

### Software

- We built a register for drones and charging stations on the Ethereum blockchain. I refactored parts of it later. You can find the solidity file in this repo: [Solidity drone charging register](https://github.com/DanielPollithy/solidity_drone) The interaction with the smart contracts happened with D3.js.
- Then there was a good looking UI for the booking process and monitoring shown in the final presentation: [Booking UI](https://github.com/gosticks/DroneChainWeb)
- But what we spent most of the time on was the communication between the drone and the charging station. They communicated via Bluetooth, had a small protocol to exchange addresses and measured their distance with the signal strength. [Bluetooth drone communication](https://github.com/DanielPollithy/bluetooth_drone)
- The drone and the charging station were connected to a websocket server to monitor their position, status and so on.
- Configuration: We attached some init.d services to the raspby and the hikey in order to survive a battery shortage. The relais control of the inductive charging station was built with some c++ code. Both boards had a small json storage to keep track of the state and future tasks.

### Code examples

![mainnet.jpg]({{site.baseurl}}/images/mainnet.jpg)

#### The relais control

```
#include <string>
#include <unistd.h>
#include "mraa.hpp"

int main(int argc, char* argv[])
{
    if (argc != 2) {
	return 1;
    }

    std::string new_state = argv[1];

    mraa::Gpio* relay_gpio = new mraa::Gpio(27);
    mraa::Result response;

    response = relay_gpio->dir(mraa::DIR_OUT);
    if (response != mraa::SUCCESS) {
        return 1;
    }
    
    if (new_state == "on") {
        relay_gpio->write(true);
    } else {
        relay_gpio->write(false);
    }

    delete relay_gpio;
    return response;
}

```

For some convenience we wrapped the calling of the cpp executable in two python functions:

```
from subprocess import Popen


def switch_off():
    popen = Popen(['sudo', '/home/linaro/bluetooth_drone/touch_switch', 'off'])
    popen.wait()


def switch_on():
    popen = Popen(['sudo', '/home/linaro/bluetooth_drone/touch_switch', 'on'])
    popen.wait()

```

#### Making a booking on the ethereum blockchain

The following javascript file accepts the drone's and station's address via commandline, registers a new booking and waits for the result which is returned by process exit codes.

```
var process = require('process');

if (process.argv.length < 4) {
    return 1;
}

// 1) get commandline argument: Is the drone's ethereum address
var drone_eth_address = process.argv[2].toLowerCase();
var station_eth_address = process.argv[3].toLowerCase();

var Web3 = require('web3');
var settings = require('./settings');

web3 = new Web3(new Web3.providers.HttpProvider(settings.node_url));

// Replace with real data if you want to use this
web3.personal.unlockAccount(drone_eth_address, <123>, <0x249F0>);

var contract = web3.eth.contract(settings.ABI).at(station_eth_address);

contract.register({from: drone_eth_address}, (e, r) => {
  console.log(e,r);
  var registered = contract.Registered();
    registered.watch(function(error, result){
        console.log(error, result);
        var addr_drone = result.args["_drone"].toLowerCase();
        var success = result.args["result"];
        if (addr_drone == drone_eth_address) {
            console.log("This is my booking");
            if (success) {
                console.log("Booking successful");
                process.exit(0);
            } else {
                console.log("Booking NOT successful");
                process.exit(1);
            }
        } else {
            console.log("NOT my booking");
        }
    });
});
```

## Presentation

The nights were short, we had a lot of things to fiddle around with until the last day and were dead tired when the presentations begun. Fortunately we had two presentators who did a good job. The jury awarded our project, we celebrated together and after a long week together we parted ways. 

![drone_flying.JPG]({{site.baseurl}}/images/drone_flying.JPG)


## What stays

I like to think back to this event because we really had a good time, talked to programmers from all over the world and learned a lot. What really impressed my about this hackathon was the fact that all groups were working together, nobody was hiding their achievements and in the end everybody could benefit from the community.
