---
title: CreativeQ Project Reflection
date: 2014-06-29
preview: Reflecting on the development of my first production Rails application.
category: Reflection
---

### Context

The Office of Student Involvement at UCF has a team of graphic designers, web designers, and video production specialists to help market its many events. Because there are many groups within the office (student-led organizations that range from campus activities to volunteering), the "creatives" use a work order management system to collect, delegate, and track requests. Prior to this project, the graphic designers used a system called DesignQ, built using Ruby on Rails by [Bill Columbia](http://billcolumbia.me) during his time at OSI. My job was to transform DesignQ into CreativeQ, a system that would also incorporate requests for web and video work (as well as various minor changes/improvements).

For the purpose of learning more about Rails, I chose to develop CreativeQ from scratch with as little support from DesignQ as possible. The following is a reflection of that process.

### Planning

It turns out, sketching out the models and their attributes is my favorite part of the Rails process. My coworker [JP](http://jpcostallos.com) and I stood in front of a whiteboard and talked through how different people would use the application. Luckily for us, we had seen how people used DesignQ. The "nouns" were simple: Users create Orders and are Assigned to Organizations. There are three main models and one join model between users and organizations.

Attributes of the User model are straightforward. An e-mail serves as a good login because most of the users have @ucf.edu e-mail addresses based on their position in the organization. Not only is this a succinct way of telling the creative what role a requester plays in their organization, it also allows accounts to be passed on when personnel change. A name is obviously important, and for ease of sorting there are separate first_name and last_name attributes. For authorization, there is a "role" attribute.

In DesignQ, the roles were Unapproved, Basic, Designer, Advisor, and Admin. Basic users generally requested the orders, Advisors approved them, and Designers completed them. While this makes sense (roles have a one-to-one correspondence for the action a user is most likely to perform) I did not like the coupling of the advisor role and their organization assignments. To me, it makes more sense to shift the idea of being an advisor to the organization assignment model.

As a result, the organization assignment model connects a user with an organization, and has a single auxiliary attribute: "role", which describes the user as either a member or an advisor.

Organizations are simply named groups of users, though in the future it may be helpful to store statistics about the organization within the model.

Orders were the main focus of our discussion. Abstracting the model's structure from the graphics-only setup of DesignQ to something that supports graphics, web, and video orders was the entire purpose of the application. Some things are constant across all orders: each has a name, a due date, and a large text description. A "type" attribute is necessary to scope which orders each creative sees. Sometimes the order has an event associated, in which case an event location and date/time is helpful. Finally, every order has a series of needs.

Needs take on very different forms depending on the type of order. For graphics, these are often sizes (handbill, poster, A-frame, etc.). For web they are tasks (new website, new design, new content). Video production orders are even more diverse. The cleanest way to store the needs of each order in a type-agnostic way seems to be a hash. We use PostgreSQL, and with Rails 4 there is native support for the `hstore` data type.

A hash doesn't care whether its contents relate to a specific type of order, where separate fields would. Still, the process of setting the possible needs for a requester to choose from has to be clean. I decided to make the lists of needs an attribute of the Order class (essentially a series of arrays) from which the controllers and views derive what they need.

Pros:

* Changing the possible needs of an order only requires modifying an array of human-readable values in the order model.
* The same list decides both the form fields to display and which hash values to check for when displaying information about the order.

Cons:

* Using the array generally requires transforming its strings into symbols.
* The behavior of the need-related fields is different for each order. For example, while graphics orders require the requester to input a size for each need (i.e. `{:handbill => '4" x 6"', :poster => '11" x 17"'}`), web orders don't require any input (`{:new_design => ''}`) and video production orders only allow the requester to choose one type of video at a time (pre-event promotion, post-event recap, etc.). Thus, while the needs can be iterated to create form fields, those fields are not type-agnostic.

Still, a hash seems like the cleanest way to store the data in this relatively small-scale application. While we're at it, we might as well use an `hstore` attribute for the related-event information as well, since it is all optional.

### Implementation Difficulties

Although the majority of the application's implementation went smoothly, there is always some trouble along the way.

**What orders can you read?** The logic surrounding just which orders should be shown is not difficult, but complicated by the lack of an "#or" in Active Record. In the order index action, I would prefer to rely on Postgres to pick out the superset of all orders a user may view (orders he/she owns, claims, can claim, or advises); a database engine is created with such a task in mind, and Ruby is comparatively slow at iterating through orders and checking readability. Of course, the office will never grow to a scale for this to matter, but that's *no excuse* for poor code design.

Unfortunately this requires writing long SQL statements within the Active Record queries: `scope :readable, -> (user) { where("owner_id = ? OR creative_id = ? OR ...`. *Note: I could have jumped into Arel and written my queries in that manner, but that would severely hinder the readability of the code. In my view, friends don't force their successors to dive into Arel.*

If #or is added (see [this pull request](https://github.com/rails/rails/pull/9052)), the query could be split into separate scopes and chained together with #or.

**Why are there so many queries?** There are a lot of unnecessary database queries being made throughout the application, and this is something I'm still working on. Proper use of joins() would solve a lot of this easily. It's just a matter of testing with a proper data set and tracking down the source.

**Why doesn't FancyBox work?** Oh, Turbolinks. I really enjoyed the mystery of the unresponsive FancyBox; because the plugin adds an element to the page and initializes on `$(document).ready()`, it doesn't work when Turbolinks loads the page and `ready()` is never fired. A [slightly modified version of the plugin](https://github.com/mikbe/fancybox2-rails) works well enough for now, but there are still problems: most importantly, FancyBox does not work when you've used the browser's back button. I've forked mikbe's repository and continue to investigate the best way to handle this. *Hint: use another plugin if you can.*

### Looking Forward

There are a few minor changes that need to be made for video production orders. Given that they've never used a work-order system before, it isn't surprising that both the system and the producers need to adjust for one another. Besides that, there are a few things I'd like to add:

* User and order retirement policy: data about users and their orders doesn't need to be kept long after they leave the office. Although users sometimes like to refer to past orders (especially for recurring events), this never occurs for orders more than a year old. At the least, retiring data to an archive database would assist with query speeds. A monthly cron-like feature could 1) warn administrators of the Users to be removed next month and 2) automatically remove users whose updated_at dates are greater than three years in the past.
* Attaching files: this is one of the most popular requests. This is not difficult to do, but it is difficult to decide how the feature should fit into the existing communication between creatives, requesters, and their advisors. If added, the feature should also encapsulate the process of approving the design or production.
* Order statistics: I'm actively working on adding statistics throughout the app: how many orders did an organization make in the past __ months? How many orders were completed by each designer? What's the average length of time for the orders?

**Most Importantly**, there is a set of common tasks that should be documented. For example, the needs of each type of order can be changed in the order model. This is something that a future web designer in my position will want to do.

### Conclusion

CreativeQ was a lot of fun to build, and I enjoyed seeing the project through from start to finish. There are many things you just can't learn until you endeavor to put a project in production.

Many thanks to OSI for allowing me to take on the project on their time, and for supporting the use of Rails. Also, a big thank you to [Bill](http://billcolumbia.me) for making DesignQ and getting me interested in Rails to begin with.

You can check out the source of the project [on GitHub](https://github.com/aj-foster/CreativeQ). Please do feel free, dear reader, to open issues and start discussion on anything you notice about the application. If you have use for something similar, talk to me! I'm happy to offer you the lessons I learned while building this.

As always, contact me [on Twitter](http://twitter.com/austin_j_foster) anytime.