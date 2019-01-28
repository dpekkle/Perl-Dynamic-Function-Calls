package utility::status;

sub get_default_status
{
	my $param = shift;

	return $param eq 'upper' ? uc 'ready' : 'ready'; 
}

1;
