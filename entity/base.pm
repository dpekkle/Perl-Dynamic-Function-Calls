package entity::base;

sub new
{
	my $class = shift;
	my $self = {};
	bless $self, $class;
}

sub get_utility_package
{
	my $self = shift;
	my $table = $self->get_table();

	my $map = {
		job  => 'utility::job',
		sale => 'utility::sale',
	};

	return $map->{$table};
}

sub call_utility_file
{
	my $self = shift;
	my ($function, $params) = @_;

	my $module = $self->get_utility_package();
	eval "require $module";
	die $@ if $@;

	# Can will actually return a coderef that we can call without worrying about the class being the first param when called,
	# Meaning we don't have to do something like `my $self = shift if ($_[0] eq 'utility::job')` in utility::job::get_default_status
	my $coderef = $module->can($function);

	return $coderef ? $coderef->($params) : undef;
}

sub get_default_status
{
	my $self = shift;

	my ($params) = @_;

	my $status = $self->call_utility_file('get_default_status', $params);

	unless ($status) {
		require utility::status;
		$status =  utility::status::get_default_status($params);
	}

	return $status;
}

1;