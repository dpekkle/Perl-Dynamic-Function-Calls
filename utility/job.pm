package utility::job;

sub get_default_status
{
	my $param = shift;

	return $param eq 'upper' ? uc 'pending' : 'pending'; 
}

1;
