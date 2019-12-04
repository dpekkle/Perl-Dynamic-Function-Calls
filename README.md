# Perl-Dynamic-Function-Calls
A demonstration of how to call a function (not method) from a dynamic package in Perl.

The below is a explanation of how I came to the solution implemented in this repository.

## Use Case

I'm presuming you have a decent use case for having functions split up into modules, and then needing to figure out what module to call. 
For example, you have classes/objects that you instantiate and call methods upon, but also have separate utility files that hold functions relating to those objects that do not operate on a single, or even any instance of the class.

e.g.

```
# Single case
my $lion = Lion->new(id => 10); #load a specific Lion from the database
$lion->hunt(); #Involves some SQL operations

# Many case
my \@lionesses = Lion::Utility::fetch_adult_females();
Lion::Utility::bulk_hunt(\@lionesses); #Done in bulk for performance
```

A good way to handle this is to have Lion::Hunt call Lion::Utility::bulk_hunt($self); to keep a single source of truth of hunting implementation.

But what if you don't just have lions, but also have tigers, birds, fish, and other predators, some of which have specific implementations of hunting, while others (like tigers and lions) share functionality? How do avoid reimplementing excess code?

## Solution

Imagine you have a couple of files that implement functions with the same name, with different implementations

```
package Foo::Bar;

sub get_full_name
{
  my $upper_case = shift;
  my $full_name = 'Archibald Foo';
  return $upper_case ? uc $full_name : $full_name;
}

package Foo::Baz;

sub get_full_name
{
  my $upper_case = shift;
  my $full_name = 'Clementine Bar';
  return $upper_case ? uc $full_name : $full_name;

}
```

You might want to do something like

```
#main.pl

sub dynamic_full_name
{
    my $package = shift;
    my $upper_case = shift;
    require $package;
    
    return $package::get_full_name($upper_case);
}

dynamic_full_name('Foo::Bar', 1);
#expecting ARCHIBALD FOO
```

However this does not work, and will fail when trying to require.

### How to load the dynamic package

#### Module::Load
Instead you could try using https://metacpan.org/pod/Module::Load i.e.
Module::Load::load($package).

That means you would have to call

```
#main.pl

sub dynamic_full_name
{
    my $package = shift;
    my $upper_case = shift;
    require Module::Load;
    Module::Load::load($package);
    
    return $package->get_full_name($upper_case); # Must be called as an instance
}

dynamic_full_name('Foo::Bar', 1);

```

#### Build a path

Alternatively, you can from the package name construct the path to the file.

For example

```
sub get_module_path
{
  my $module = shift;
  my $path = $module;
  $path =~ s/::/\//g; #replace :: with /
  $path .= '.pm';
  return $path;
}

require get_module_path('Foo::Bar');

```

### Handling parameters

Now that you can import the module, you are left in a situation where the first parameter passed into the `get_full_name`
subroutine is not the $upper_case variable but instead the name of the package. 

Presumably you still want to be able to call the function directly from the module (otherwise this could just be done via classes/objects) 
However when doing so the first parameter won't be the package name e.g. Foo::Bar::get_full_name(1) only has 1 param.

Some solutions to this are to have a conditional shifting of parameters. E.g.

``` 
package Foo::Bar;

sub get_full_name
{
  my $package = shift if $_[0] eq 'Foo::Bar';
  my $upper_case = shift;
  my $full_name = 'Archibald Foo';
  return $upper_case ? uc $full_name : $full_name;
}
```

However this is a pretty annoying solution as you'll have to include this in every function that might be called.

Instead you can make use of the [UNIVERSAL::can](https://perldoc.perl.org/UNIVERSAL.html) method to get the code reference to the subroutine you are seeking.
e.g.

```
#main.pl

sub dynamic_full_name
{
    my $package = shift;
    my $upper_case = shift;
    require Module::Load;
    Module::Load::load($package);
    
    return $package->can('get_full_name')->($upper_case);
}

dynamic_full_name('Foo::Bar', 1);
# returns ARCHIBALD FOO
```

Success!
