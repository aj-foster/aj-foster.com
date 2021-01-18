---
title: Tombstones in Typography
date: 2015-11-20
preview: Thoughts and examples of using the tombstone in typography on the web.
category: Guide
---

If you search for information on this topic, you're likely to get a bunch of articles on the typography found on tombstones (a very interesting topic). So just to be clear: this article concerns the typographic symbol called the *tombstone*, which is used to mark the end of various written pieces.

### A little history

Although many people (myself included) know the tombstone from mathematics as the "end of proof" or "Q.E.D." symbol, it was first used to mark the end of articles in magazines and other written contexts. As [a quick search](https://en.wikipedia.org/wiki/Tombstone_%28typography%29) will point out, the symbol might also be called the *Halmos* after the individual who apparently introduced it to mathematics.

It appears the tombstone has only partially made the transition into web publications. A quick survey of the [top 50](http://www.journalism.org/media-indicators/digital-top-50-online-news-entities-2015/) online news sites (for this, ad blocking software is recommended) reveals that almost nobody uses it, with the exception of a round red dot from the UK publisher [The Independent](http://www.independent.co.uk) and the company logo from [NBC News](http://www.nbcnews.com/). Most others simply end an article with a copyright remark or our dear friend, the comment section. *(If you see the tombstone or another similar end-mark in use, I'd love to add examples at the end of this article.)*

### Evaluating its purpose

In any case, such a symbol serves to separate the main content from whatever may follow, whether it be another article, an editorial remark, or - let's be honest - an advertisement. It's easy to see why this proved useful in the context of a magazine, which may have text displaced all throughout the page due to images and the like. Seeing a small box at the end of the paragraph alerted the reader that something new awaited them on the next page.

I'd argue this remains important on the web. With advertisements looking increasingly like other content, and last year's trend of infinitely scrolling news stories, it can be difficult to pinpoint where the main content ends. Perhaps this is good for publishers who wish to present advertisements, but it places a small mental tax on readers.

### Implementing it

Let's first take a look at how The Independent and NBC News implement their marks:

<pre>
<code>
<span style="color: #75715e">/* Styles taken from http://www.independent.co.uk */</span>&#32;
<span style="color: #f8f8f2">.</span><span style="color: #a6e22e">full-article</span>&#32;<span style="color: #f8f8f2">.</span><span style="color: #a6e22e">text-wrapper</span>&#32;
  <span style="color: #f92672">&gt;</span>&#32;<span style="color: #f92672">p</span><span style="color: #f8f8f2">:</span><span style="color: #a6e22e">last-of-type</span><span style="color: #f8f8f2">::</span><span style="color: #a6e22e">after</span>&#32;<span style="color: #f8f8f2">{</span>&#32;
    <span style="color: #66d9ef">background</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #ae81ff">#EC1A2E</span>&#32;<span style="color: #66d9ef">none</span>&#32;<span style="color: #66d9ef">repeat</span>&#32;<span style="color: #66d9ef">scroll</span>&#32;<span style="color: #ae81ff">0</span><span style="color: #66d9ef">%</span>&#32;<span style="color: #ae81ff">0</span><span style="color: #66d9ef">%</span><span style="color: #f8f8f2">;</span>&#32;
    <span style="color: #66d9ef">border-radius</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #ae81ff">8</span><span style="color: #66d9ef">px</span><span style="color: #f8f8f2">;</span>&#32;
    <span style="color: #66d9ef">content</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #e6db74">" "</span><span style="color: #f8f8f2">;</span>&#32;
    <span style="color: #66d9ef">display</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #66d9ef">inline-block</span><span style="color: #f8f8f2">;</span>&#32;
    <span style="color: #66d9ef">height</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #ae81ff">16</span><span style="color: #66d9ef">px</span><span style="color: #f8f8f2">;</span>&#32;
    <span style="color: #66d9ef">left</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #ae81ff">6</span><span style="color: #66d9ef">px</span><span style="color: #f8f8f2">;</span>&#32;
    <span style="color: #66d9ef">position</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #66d9ef">relative</span><span style="color: #f8f8f2">;</span>&#32;
    <span style="color: #66d9ef">top</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #ae81ff">2</span><span style="color: #66d9ef">px</span><span style="color: #f8f8f2">;</span>&#32;
    <span style="color: #66d9ef">width</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #ae81ff">16</span><span style="color: #66d9ef">px</span><span style="color: #f8f8f2">;</span>&#32;
<span style="color: #f8f8f2">}</span>&#32;
&#32;
<span style="color: #75715e">/* Styles taken from http://www.nbcnews.com */</span>&#32;
<span style="color: #f8f8f2">.</span><span style="color: #a6e22e">article-body</span>&#32;
  <span style="color: #f92672">&gt;</span>&#32;<span style="color: #f92672">p</span><span style="color: #f8f8f2">:</span><span style="color: #a6e22e">last-child</span><span style="color: #f8f8f2">::</span><span style="color: #a6e22e">after</span>&#32;<span style="color: #f8f8f2">{</span>&#32;
    <span style="color: #66d9ef">background-image</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #f8f8f2">url(</span><span style="color: #e6db74">...</span><span style="color: #f8f8f2">);</span>&#32;
    <span style="color: #66d9ef">background-repeat</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #66d9ef">no-repeat</span><span style="color: #f8f8f2">;</span>&#32;
    <span style="color: #66d9ef">background-size</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #ae81ff">18</span><span style="color: #66d9ef">px</span>&#32;<span style="color: #66d9ef">auto</span><span style="color: #f8f8f2">;</span>&#32;
    <span style="color: #66d9ef">bottom</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #ae81ff">-8</span><span style="color: #66d9ef">px</span><span style="color: #f8f8f2">;</span>&#32;
    <span style="color: #66d9ef">content</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #e6db74">""</span><span style="color: #f8f8f2">;</span>&#32;
    <span style="color: #66d9ef">display</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #66d9ef">inline-block</span><span style="color: #f8f8f2">;</span>&#32;
    <span style="color: #66d9ef">height</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #ae81ff">18</span><span style="color: #66d9ef">px</span><span style="color: #f8f8f2">;</span>&#32;
    <span style="color: #66d9ef">position</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #66d9ef">relative</span><span style="color: #f8f8f2">;</span>&#32;
    <span style="color: #66d9ef">width</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #ae81ff">18</span><span style="color: #66d9ef">px</span><span style="color: #f8f8f2">;</span>&#32;
<span style="color: #f8f8f2">}</span>
</code>
</pre>

Between these two, I prefer `p:last-of-type` to `p:last-child` since it allows writers to put non-textual content afterwards with no issue. NBC's logo simply doesn't show if the article ends with a photo or blockquote.

Based on these, and my own requirements / opinions, I've settled upon this:

<pre>
<code>
<span style="color: #f8f8f2">.</span><span style="color: #a6e22e">article</span>&#32;<span style="color: #f92672">&gt;</span>&#32;<span style="color: #f92672">p</span><span style="color: #f8f8f2">:</span><span style="color: #a6e22e">last-of-type</span><span style="color: #f8f8f2">::</span><span style="color: #a6e22e">after</span>&#32;<span style="color: #f8f8f2">{</span>&#32;
    <span style="color: #66d9ef">border</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #ae81ff">1</span><span style="color: #66d9ef">px</span>&#32;<span style="color: #66d9ef">solid</span>&#32;<span style="color: #66d9ef">currentColor</span><span style="color: #f8f8f2">;</span>&#32;
    <span style="color: #66d9ef">content</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #e6db74">''</span><span style="color: #f8f8f2">;</span>&#32;
    <span style="color: #66d9ef">display</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #66d9ef">block</span><span style="color: #f8f8f2">;</span>&#32;
    <span style="color: #66d9ef">float</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #66d9ef">right</span><span style="color: #f8f8f2">;</span>&#32;
    <span style="color: #66d9ef">position</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #66d9ef">relative</span><span style="color: #f8f8f2">;</span>&#32;
&#32;
    <span style="color: #75715e">/* To be changed based on typeface */</span>&#32;
    <span style="color: #66d9ef">height</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #ae81ff">0.625</span><span style="color: #66d9ef">em</span><span style="color: #f8f8f2">;</span>&#32;
    <span style="color: #66d9ef">margin-left</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #ae81ff">0.3</span><span style="color: #66d9ef">em</span><span style="color: #f8f8f2">;</span>&#32;
    <span style="color: #66d9ef">top</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #ae81ff">0.3</span><span style="color: #66d9ef">em</span><span style="color: #f8f8f2">;</span>&#32;
    <span style="color: #66d9ef">width</span><span style="color: #f8f8f2">:</span>&#32;<span style="color: #ae81ff">0.625</span><span style="color: #66d9ef">em</span><span style="color: #f8f8f2">;</span>&#32;
<span style="color: #f8f8f2">}</span>
</code>
</pre>

Of course, there is a UTF character for the tombstone (`&#8718;`). Unfortunately it suffers from wild variation by typeface - and I simply don't like the way it looks in most. Thus I've chosen to use a square box, about the cap height of the body typeface, similar to what is produced by LaTeX for mathematical documents. You might prefer the box to be filled in, which is quite common. Everything is relative and ought to adjust well with changes in the `font-size` property.

Also, I like to have the tombstone right-justified, especially if the paragraph text itself is justified. This follows partly from its use in LaTeX documents, and partly from my own preferences.

Here's a CodePen example annotated with my style suggestions, if you'd like to try it out:

<p class="codepen" data-height="265" data-theme-id="0" data-default-tab="result" data-user="aj-foster" data-slug-hash="KdYgjd" style="height: 265px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;" data-pen-title="Tombstone">
  <span>See the Pen <a href="https://codepen.io/aj-foster/pen/KdYgjd/">
  Tombstone</a> by AJ Foster (<a href="https://codepen.io/aj-foster">@aj-foster</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://static.codepen.io/assets/embed/ei.js"></script>
<br>

If you use or see the tombstone on the web, I'd love to hear about it. Happy writing!

---

<div class="addendum">
    <p>Additions &amp; Errata</p>
    <ul>
        <li>(11/22/2015) <a href="https://twitter.com/johndjameson">John D. Jameson</a> pointed out that <a href="http://www.clickhole.com/">ClickHole</a> uses a circular mark at the end of articles on their site.</li>
        <li>(1/10/2019) Marc Müller mentioned that <a href="https://blog.google/products/android/introducing-new-google-fit/">a recent Google Blog post</a> used a mark with class "tombstone."</li>
    </ul>
</div>