namespace :smart_filter do
  desc "Copies stylesheets and javascript files necessary for smart_filter without jQuery"
  task :install do
    print 'Copying files: '
    FileUtils.cp(File.expand_path('../../../public/stylesheets/smart_filter.css', __FILE__), File.expand_path('public/stylesheets/smart_filter.css', RAILS_ROOT)); print '.';
    FileUtils.cp(File.expand_path('../../../public/javascripts/smart_filter.js', __FILE__), File.expand_path('public/javascripts/smart_filter.js', RAILS_ROOT)); puts '.'
    puts <<-EOT

================================================================
Please paste the following in the head of your layout (such as
application.html.erb):

<%= stylesheet_link_tag 'smart_filter' %>
<%= javascript_include_tag 'jquery-1.4.2.min', 'smart_filter' %>

================================================================
    EOT
  end
end