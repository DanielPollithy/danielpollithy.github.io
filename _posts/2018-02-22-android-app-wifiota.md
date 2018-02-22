---
layout: post
published: true
categories:
  - personal
mathjax: false
featured: false
comments: false
title: Android app Wifiota
description: ''
headline: ''
modified: ''
tags: ''
imagefeature: ''
---
## Sharing remaining mobile data in exchange for Iota

Quick link for the impatient: [https://tobywoerthle.github.io/flashWiFiSite/](https://tobywoerthle.github.io/flashWiFiSite/)

### Prelude

The story begins in December 2017 on Reddit. Somebody was asking in the subred of Iota (not literally):


> Anybody got cool ideas for a developer to program something with the iota library?


In the comment section Toby from Canada and I were talking about the idea of "paying iota and receiving wifi". Together with Wlad we teamed up for the Iota Flash Channel Challenge.

We decided to design a protocol which enables devices with internet access to share it and get paid for it. As a starter we built an Android app because these devices bring the interesting capacities with them: 

- Mobile data plans
- Can serve an Access Point
- Are capable of WiFi Direct

<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/Co46IZxoB4c?rel=0" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>



### Quick introduction to iota flash channels

**Iota:** Iota is the name of a distributed ledger technology which breaks the underlying blockchain into a directed acyclic graph of transactions ("The Tangle"). See [Wikipedia on Iota](https://de.wikipedia.org/wiki/IOTA_(Kryptow%C3%A4hrung)) for more information. The currency on the Tangle is called iotas.
The Iota network is at a low rate  of transactions per second (around three to five TPS) as of January 2018. 

**Flash channel:** An additional library called flash.lib.js implements flash channels for Iota what brings the advantage of so called 'off-tangle' transactions. Two or more parties fund a flash channel by tranfering iotas into one multi-signature wallet.
They can now exchange iotas without interacting/waiting with/for the main-net (the tangle). Every party signs the off-tangle transactions. After everybody has transferred and signed  (aka agreed) what they wanted, the flash channel can be attached to the tangle and the iotas of the multi-signature address are distributed to the receiving parties.
**=> Short version: You can stream iotas between multiple parties with consent and partially off-line**

### Concept

The three of us wrote a 15 page Google doc that contained everything from the idea to the protocols and interesting links.

We built two protocols in Java:
- **Negotiation Protocol:** Uses WiFi Direct to find devices nearby, two peers then talk about what they offer or what they want to consume (price per megabyte etc.).
- **Billing Protocol:** If the peers agreed on conditions the seller opens a new Access Point (AP) which the buyer can join using an exchanged key from the negotiation protocol. Now that the buyer has access to the internet, both of them open a new flash channel and every minute they exchange small bills containing the used megabytes and the price in iota.

![Negotiation Protocol]({{site.baseurl}}/images/NegotiationProtocol.jpg)


The android app contains basic wallet functions for sending and receiving iotas and a lot of settings regarding payment conditions. You can see this in the  screencaptured video demonstration.

<iframe src="https://drive.google.com/file/d/1_v6PnM9ebcAoLRQRAE-wvv9_S9NYyrJP/preview" width="640" height="480"></iframe>

### Challenges

The library for the flash channels was only available in Javascript. Wlad tackled this. He tried to port it but got stuck due to the non-existant documentation and the (messy programmed) javascript functions which were unreliable in terms of parameters and return values.

So he changed the tactics and included a full javascript v8 library to the project. This v8 engine exectuted the flash channel code in javascript and returned the values to Java. The interaction with the javascript code was wrapped by Wlad into a neat Java package.

Which leads me to another challenge: Android programming with Java. With close to zero knowledge about android programming and only the basics of Java from university I spent a lot of time learning, trying , debugging und restructuring the app.
In the end it  worked out and the concepts of ForegroundServices, AsyncTask, EncryptedSharedStorage the livecycles of fragments etc. were really interesting.

WifiP2P, Wifi Direct and creating a hotspot was also challenging. The wireless APIs behave a little bit different depending on which device you are operating on. In order to debug the connection I bought a cheap android phone from the brand cubot and it was noticable that creating a hotspot and using wifi direct differs between this phone and my usual OnePlusX.

### Testing environment

In the beginning we wanted to use Iota's Mainnet but the low TPS brought us to the public testnet. One weekend this net was so stuffed by a spammer we decided to setup a private testnet with a single node.

I made some changes to the sourcecode of the official Iota node implementation called IRI, built an API that provided addresses with 2000i (2000 Iota) each, created a small script that brings some traction on the testnode by making random transactions, finally let the coordinator run every minute and we were good to go.

### Handing in

After working for two to three weeks on it we got into time pressure because - as always - things took longer because they were not working as expected and so on.
In the night before the deadline of the flash channel competition we did not go to sleep because we really tried to fix every bug and so on. 

At around 5am we were capturing the videos:
<iframe src="https://drive.google.com/file/d/1PAC1FrRnyhdQTYpWPdqNc71wyH1UuoXt/preview" width="640" height="480"></iframe>

Luckily Toby from Canada was in a different timezone so when we were dead tired in Germany at 10am he just came back from work and could concentrate on our website for the project: [https://tobywoerthle.github.io/flashWiFiSite/](https://tobywoerthle.github.io/flashWiFiSite/)

**In the end:** We did not win. There were similar ideas. The winner "Fognet" was also about sharing internet access in exchange for iotas but they used Arduino boards instead of Android devices.

Nevertheless we did a really good job, it was fun to work with these two guys and I learnt a lot.











