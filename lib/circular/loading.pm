use strict;
use warnings;

# ABSTRACT: Throw error with stacktrace if package is loaded circularly

package circular::loading;

use Carp qw( confess );
use B::Hooks::EndOfScope;
use namespace::clean;

$Carp::Internal{ +__PACKAGE__ }++;

sub unimport {
    my $caller = caller;

    ( my $path = $caller ) =~ s{::}{/}g;
    $path .= '.pm';

    my $entry = delete $INC{ $path };

    on_scope_end { 
        no warnings; 
        $INC{ $path } = $entry;
    };

    my $level = 1;
    while (my ($package) = ( caller ++$level )) {

        confess "Circular loading of class '$caller'"
            if $package eq $caller;
    }

    return 1;
}

1;

__END__

=head1 SYNOPSIS

    package Foo;
    no circular::loading;

    # ...

    1;

=head1 DESCRIPTION

This is a rather simple module. You C<use> it at the top of your file right
after your package declaration (this is important). It will throw an error
including a stacktrace if the package is required again without having been
fully compiled. It does that by deferring the entry in C<%INC> that usually
happens at load time until the end of compilation time with the help of
L<B::Hooks::EndOfScope>.

=head1 CAVEAT

The package's C<%INC> entry will not be available until after compile time.
This means the package won't be seen as loaded by the packages C<use>d after
C<no circular::loading>.

Another non-nicety is that you'll have to put the C<no circular::loading>
declaration first in your package as to not import from other packages
multiple times. This might not break anything, but it might hide the real
circular error from you.

=method unimport

This is the method called when

    no circular:loading;

is used. There is no corresponding C<import> method at the moment.

=cut
