---
layout: post
published: true
mathjax: false
featured: false
comments: false
title: Simulating heat flow with Fourier
description: With the help of the Fourier transformation functions can be approximated
  with a mixture of sine and cosine waves. This can be used to simulate how a medium
  of different temperatures evolves over time.
categories:
  - general
---

I recently read the book "Infinite Powers" by Steven Strogatz. In chapter 10
he told the story of Joseph Fourier and why he initially cared about approximating
functions with a mixture of sine and cosine waves.

His objective was to solve the "heat problem". How does the heat distribute in
an a rod (or regarding electric circuits: in a wire). For some backgrounds see
the section "background".

The following section contains a demo of such a wire that can cool down.
By clicking on the first wire you can draw heat patterns which are smoothed
with a Fourier transformations (actually by setting the higher order coefficients to zero).
In the case that the "simulate" check-box was active, then the simulation will start
after clicking on the wire.

### Demo

<p id="status" style="border: solid 2px green;">Status: Ready</p>

  <p>Input (click on the left half of the bar):</p>
  <p>
  <canvas id="canvas" width="800" height="15" style="border: 1px solid black; margin: 0; padding: 0;"></canvas>
  </p>

  <p>Betragsspektrum:</p>
  <p>
  <canvas id="heatmap" width="401" height="15" style="border: 1px solid black; margin: 0; padding: 0;"></canvas>
  </p>

  <p>Abgeschnittenes Betragsspektrum:</p>
    <p>
  <canvas id="heatmap2" width="401" height="15" style="border: 1px solid black; margin: 0; padding: 0;"></canvas>
  </p>

  <p>Output:</p>
  <p>
  <canvas id="output" width="400" height="15" style="border: 1px solid black; margin: 0; padding: 0;"></canvas>
  </p>

  <p>Cooling:</p>
  <p>
  <canvas id="cooling" width="400" height="15" style="border: 1px solid black; margin: 0; padding: 0;"></canvas>
  </p>

  <br>
  <b>FFT coefficients:</b>
   1... <input type="range" onchange="limit=parseInt(event.srcElement.value)" min="1" max="400" value="400"> ... 400
   <br>
   <b>Simulate cooling:</b>
   <input type="checkbox" onchange="simulate=event.srcElement.checked" name="subscribe" checked>


   <script src="https://cdnjs.cloudflare.com/ajax/libs/tensorflow/1.2.2/tf.js" integrity="sha256-nmpYdNs3Fhti+a0TX7xkb8SVRzaUgZOfafDbgtvCoGk=" crossorigin="anonymous"></script>

<script type="text/javascript">
    var canvas = document.getElementById("canvas");
    var context = canvas.getContext("2d");
    var width = 800;
    var height = 15;
    var radius = 30;
    var limit = 10;


    var canvas2 = document.getElementById("heatmap");
    var context2 = canvas2.getContext("2d");

    var canvas3 = document.getElementById("heatmap2");
    var context3 = canvas3.getContext("2d");

    var canvas4 = document.getElementById("output");
    var context4 = canvas4.getContext("2d");

    var canvas5 = document.getElementById("cooling");
    var context5 = canvas5.getContext("2d");

    var status_p = document.getElementById("status")

    real_state = null;
    imag_state = null;

    var start = null;
    var max = null;
    var busy = false;
    var simulate = true;
    var fps = 60;
    var animation_durance = 250 * width / fps;  // milliseconds

    function getMousePos(canvas, evt) {
        var rect = canvas.getBoundingClientRect();
        return {
          x: evt.clientX - rect.left,
          y: evt.clientY - rect.top
        };
    }

    function draw(evt) {
        if (busy) return
        busy_on()
        var pos = getMousePos(canvas, evt);

        context.fillStyle = "rgba(0, 0, 0, 0.25)";
        context.fillRect (pos.x-radius/2.0, pos.y-radius/2.0, radius, radius);

        updateMap();
    }

    function heatmapToImage(heatmap, ctx, width_pixels) {
      heatmap = heatmap.map(x => (x-min)/(max-min))

      var image = [];
      for (var n=0; n<height; n++) {
        for (var i=0; i<heatmap.length; i++) {
          image.push(0);
          image.push(0);
          image.push(0);
          image.push(255.0 * heatmap[i]);
        }
      }

      var imgData = new ImageData(new Uint8ClampedArray(image), width_pixels, height)

      ctx.putImageData(imgData, 0, 0);
    }

    function cut_limit(x, idx) {
      if (idx>limit) {
        return 0;
      } else {
        return x;
      }
    }

    function busy_off(){
      busy = false;
      status_p.innerHTML = "Status: Ready";
      status_p.style.setProperty('border-color', 'green')
    }

    function busy_on(){
      busy = true;
      status_p.innerHTML = "Status: Busy";
      status_p.style.setProperty('border-color', 'red')
    }

    function draw_canvas() {
      var timestamp = new Date().getTime()
      if (!start) start = timestamp;
      var progress = timestamp - start;
      var relative_progress = progress / animation_durance;

      context5.globalCompositeOperation = 'destination-over';
      context5.clearRect(0, 0, 400, 15); // clear canvas

      real_state = real_state.map((x, idx, ary) => x - idx/real_state.length * x)
      imag_state = imag_state.map((x, idx, ary) => x - idx/imag_state.length * x)


      const state = tf.complex(tf.tensor1d(real_state), tf.tensor1d(imag_state));

      var output = state.irfft().dataSync();

      heatmapToImage(output.slice(0,400), context5, 400);

      if (progress < animation_durance) {
        setTimeout(draw_canvas, 1000/fps);
      } else {
        start = null;
        busy_off()
      }
    }

    function updateMap() {
        var imageData = context.getImageData(0, 0, 401, height);

        var firstRow = imageData.data.slice(0, width*4);

        var rgba_pixels = firstRow.filter(function(value, index, Arr) {
            return (index+1) % 4 == 0;
        });

        const real = tf.tensor1d(Array.from(rgba_pixels));
        var coeff = real.rfft().dataSync();

        var betrag = [];
        var imag_array = [];
        var real_array = []
        for (var i=0; i<coeff.length - 1; i+=2) {
          betrag.push(Math.sqrt(coeff[i]**2 + coeff[i+1]**2))
          real_array.push(coeff[i])
          imag_array.push(coeff[i+1])
        }

        min = Math.min(...betrag)
        max = Math.max(...betrag)
        heatmapToImage(betrag, context2, 401);

        // ifft
        real_array = real_array.map(cut_limit);
        imag_array = imag_array.map(cut_limit);

        var betrag2 = [];
        for (var i=0; i<real_array.length; i+=1) {
          betrag2.push(Math.sqrt(real_array[i]**2 + imag_array[i]**2))
        }

        min = Math.min(...betrag2)
        max = Math.max(...betrag2)
        heatmapToImage(betrag2, context3, 401);

        // global store
        real_state = real_array.slice();
        imag_state = imag_array.slice();

        const state = tf.complex(tf.tensor1d(real_array), tf.tensor1d(imag_array));

        var output = state.irfft().dataSync();

        min = Math.min(...output)
        max = Math.max(...output)
        heatmapToImage(output.slice(0,400), context4, 400);

        if (simulate) {
          setTimeout(draw_canvas, 1000/60);
        } else {
          busy_off()
        }
    }

    canvas.addEventListener('click', draw);
</script>


### Background

Initially I wanted to write a little bit about this but I found that 3b1b just
published a video about this:

<p>
  <figure>
    <div class="videoWrapper">
      <iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/ToIXSwZ1pJU" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
    </div>
  </figure>
</p>
