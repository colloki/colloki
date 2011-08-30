require 'mongrel_cluster/recipes'

set :application, "slurp.cs.vt.edu"
set :repository,  "http://subversion.assembla.com/svn/colloki/trunk"

set :user, "deploy"
set :deploy_to, "/home/deploy/slurp"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "slurp.cs.vt.edu"
role :web, "slurp.cs.vt.edu"
role :db,  "slurp.cs.vt.edu", :primary => true

set :rails_env, "production"

# Cluster Config
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

#We're going to deploy via workstation; i.e., the server never accesses the SVN. The workstation does that, then zips up the file and send it via ssh to the remote server.
set :deploy_via, :copy

#Setting which user runs the mongrel instances
set :runner, deploy

task :after_update_code do
  #For files under config/ folder
  %w{database.yml environment.rb}.each do |config|
    run "ln -nfs #{shared_path}/config/#{config} #{release_path}/config/#{config}"
  end
  
  #For files under config/initializers folder
  %w{mail.rb}.each do |config|
    run "ln -nfs #{shared_path}/config/initializers/#{config} #{release_path}/config/initializers/#{config}"
  end  
end

