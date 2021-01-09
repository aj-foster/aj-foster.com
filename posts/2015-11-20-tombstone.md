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

~~~css
/* Styles taken from http://www.independent.co.uk */
.full-article .text-wrapper
  > p:last-of-type::after {
    background: #EC1A2E none repeat scroll 0% 0%;
    border-radius: 8px;
    content: " ";
    display: inline-block;
    height: 16px;
    left: 6px;
    position: relative;
    top: 2px;
    width: 16px;
}

/* Styles taken from http://www.nbcnews.com */
.article-body
  > p:last-child::after {
    background-image: url(...);
    background-repeat: no-repeat;
    background-size: 18px auto;
    bottom: -8px;
    content: "";
    display: inline-block;
    height: 18px;
    position: relative;
    width: 18px;
}
~~~

Between these two, I prefer `p:last-of-type` to `p:last-child` since it allows writers to put non-textual content afterwards with no issue. NBC's logo simply doesn't show if the article ends with a photo or blockquote.

Based on these, and my own requirements / opinions, I've settled upon this:

~~~css
.article > p:last-of-type::after {
    border: 1px solid currentColor;
    content: '';
    display: block;
    float: right;
    position: relative;

    /* To be changed based on typeface */
    height: 0.625em;
    margin-left: 0.3em;
    top: 0.3em;
    width: 0.625em;
}
~~~

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