xml.instruct!
xml.feed 'xmlns' => 'http://www.w3.org/2005/Atom' do
  site_url = 'https://aj-foster.com/'
  xml.title 'AJ Foster'
  xml.subtitle 'Web, Math, and Robotics'
  xml.id site_url
  xml.link 'href' =>site_url
  xml.link 'href' => URI.join(site_url, current_page.path), 'rel' => 'self'
  xml.updated(get_articles.first.data.date.to_time.iso8601) unless get_articles.empty?
  xml.author { xml.name 'AJ Foster' }

  get_articles(10).each do |post|
    xml.entry do
      xml.title post.data.title
      xml.link 'rel' => 'alternate', 'href' => URI.join(site_url, post.url)
      xml.id URI.join(site_url, post.url)
      xml.published post.data.date.to_time.iso8601
      xml.updated File.mtime(post.source_file).iso8601
      xml.author { xml.name 'AJ Foster' }
      xml.summary post.data.description, 'type' => 'html'
      xml.content post.render(layout: false), 'type' => 'html'
    end
  end
end
