# Install Database Server PostgreSQL

if rpm -qa 'postgresql-server' | grep -q postgresql; then
  echo "postgresql already installed, skipping."
else
	yum -y install postgresql postgresql-server postgresql-contrib

	# We need to initialize & start the database
	chkconfig postgresql on
	service postgresql intidb && service postgresql start

  #enable password authentication
  mv files/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf
  chown postgres:postgres /var/lib/pgsql/data/pg_hba.conf
  chmod 640 /var/lib/pgsql/data/pg_hba.conf
  sudo service postgresql restart

  #create user and database
  sudo -u postgres psql -c "create user <%= @attributes.postgres_user %> with password '<%= @attributes.postgres_password %>';"
  sudo -u postgres psql -c "create database <%= @attributes.postgres_database %> owner <%= @attributes.postgres_user %>;"
fi