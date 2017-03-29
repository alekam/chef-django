
# bash "Update locale" do
  # code <<-EOH
# echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list
# wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
# sudo apt-get update
# sudo apt-get upgrade
# sudo apt-get install postgresql-9.3 postgresql-contrib-9.3
  # EOH
# end


# execute "Update system" do
  # command "apt-get update"
# end

# bash "Update locale" do
  # code <<-EOH
  # apt-get install language-pack-ru vim -y
  # locale-gen
  # update-locale LANG=ru_RU.UTF-8
  # EOH
# end
#
# # execute "Install required postgresql packages" do
  # # command "apt-get install postgresql-9.1-postgis gdal-bin binutils libgeos-c1 libgeos-dev libgdal1-dev libpq-dev -y"
# # end
#
#
# # bash "create the template_postgis database template" do
  # # user "postgres"
  # # code <<-EOH
  # # createdb -E UTF8 -U postgres template_postgis -T template0
  # # createlang -d template_postgis plpgsql
# psql -U postgres -d template_postgis -c "CREATE EXTENSION hstore;"
# psql -U postgres -d template_postgis -f /usr/share/postgresql/9.1/contrib/postgis-1.5/postgis.sql
# psql -U postgres -d template_postgis -f /usr/share/postgresql/9.1/contrib/postgis-1.5/spatial_ref_sys.sql
# psql -U postgres -d template_postgis -c "select postgis_lib_version();"
# psql -U postgres -d template_postgis -c "GRANT ALL ON geometry_columns TO PUBLIC;"
# psql -U postgres -d template_postgis -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"
# psql -U postgres -d template_postgis -c "GRANT ALL ON geography_columns TO PUBLIC;"
  # # EOH
# # end
#
# execute "create project db" do
  # command "sudo -u postgres createdb -T #{node[:postgis][:template_name]} #{node[:django][:project_name]}"
# end
if node[:django][:create_db]
  execute "create project db" do
    command "sudo -u postgres createdb --encoding=UTF8 #{node[:django][:project_name]}"
  end
end
#
# execute "Create db" do
  # command "sudo -u postgres createdb --encoding=UTF8 project"
# end
# ALTER USER "user_name" WITH PASSWORD 'new_password';

#
#
# include_recipe  "build-essential"
# #include_recipe  "python"
#
# # execute "install system dependencies" do
  # # command "sudo apt-get -y build-dep python-mysqldb"
# # end
#
execute "create static folder" do
  command "sudo mkdir /srv/#{node[:django][:project_name]}/www/static -p"
end
execute "create media folder" do
  command "sudo mkdir /srv/#{node[:django][:project_name]}/www/media -p"
end

template "/srv/#{node[:django][:project_name]}/core/main/settings/local.py" do
  source 'local_example.py.erb'
  # mode '0440'
  # owner 'root'
  # group 'root'
  variables({})
end


execute "create virtual enviroment" do
  command "virtualenv /srv/#{node[:django][:project_name]}/env --distribute"
  action :run
end


bash "configuring pip" do
  cwd "/srv/#{node[:django][:project_name]}/env"
  code <<-EOH
  sudo chmod 0777 /usr/src
  sudo mkdir /usr/src/pip/
  sudo chmod 0777 /usr/src/pip
  mkdir /usr/src/pip
  echo "export PIP_DOWNLOAD_CACHE=/usr/src/pip" > ~/.bash_profile
  EOH
end


if node[:django][:buildout]
  bash "install buildout" do
    cwd "/srv/#{node[:django][:project_name]}/env"
    code <<-EOH
    source ./bin/activate
    pip install zc.buildout==1.7.1
    mkdir ./eggs/
    touch ./eggs/easy-install.pth
    EOH
  end
  template "/srv/#{node[:django][:project_name]}/vagrant.cfg" do
    source 'vagrant.cfg.erb'
    # mode '0440'
    # owner 'root'
    # group 'root'
    variables({
       :pip_requirements_file => node[:django][:pip_requirements_file],
    })
  end
  bash "build enviroment" do
    cwd "/srv/#{node[:django][:project_name]}"
    code <<-EOH
    ./env/bin/buildout -c ./vagrant.cfg
    EOH
  end
else
  bash "build enviroment" do
    cwd "/srv/#{node[:django][:project_name]}"
    code <<-EOH
    source ./env/bin/activate
    pip install -r #{node[:django][:pip_requirements_file]}
    EOH
  end
end
# CREATE USER root PASSWORD 'md54297f44b13955235245b2497399d7a93';
#execute "Sync db" do
#  command "./bin/django syncdb --noinput"
#  cwd "/srv/#{node[:django][:project_name]}/"
#  action :run
#end

if node[:django][:create_db]
  execute "Migrate DB" do
    command "./bin/django migrate"
    cwd "/srv/#{node[:django][:project_name]}/"
    action :run
  end
  if node[:django][:fixtures]
    node[:django][:fixtures].each do |fixture|
      execute "Load fixture from file #{fixture}" do
        command "./bin/django loaddata #{fixture}"
        cwd "/srv/#{node[:django][:project_name]}/"
        action :run
      end
    end
  end
end

if node[:django][:collectstatic]
  execute "Collect staticfiles" do
    command "./bin/django collectstatic --noinput"
    cwd "/srv/#{node[:django][:project_name]}/"
    action :run
  end
end
