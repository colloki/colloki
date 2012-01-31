##Colloki

Colloki is an online platform to encourage meaningful conversations among residents of local communities. This particular instance of Colloki focusses on Blacksburg, Montgomery County and nearby communities.

Colloki is an opensource research project being developed at the [SocialComp Group](http://diggov.cs.vt.edu) at the [Center for Human-Computer Interaction](http://hci.vt.edu) in the [Department of Computer Science](http://www.cs.vt.edu) and the [Department of Communication Studies](http://www.comm.vt.edu) at Virginia Tech.

## Installation

* Create `config/database.yml` from `config/database.yml.tmpl`

* Create `config/initializers/omniauth.rb` from `config/initializers/omniauth.rb.tmpl`

* Create `config/initializers/setup_mail.rb` from `config/initializers/setup_mail.rb.tmpl`

* Currently, ruby 1.9.2 is supported. Installing RVM is recommended (http://beginrescueend.com/): `rvm install 1.9.2`

* If you are using RVM, create `.rvmrc` in the root of the project folder.
    The content of this file should look something like: `rvm use 1.9.2`

* Install the required gems: `bundle install`

* The `nokogiri` gem may have dependencies you will need to install. 
    Macports is recommended for installing the `libxml2` and `libxslt` packages.

* `rake db:migrate`