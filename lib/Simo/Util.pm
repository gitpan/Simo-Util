package Simo::Util;

our $VERSION = '0.0205';

use warnings;
use strict;
use Simo::Wrapper;
use Simo::Error;

use Exporter;
our @ISA = qw( Exporter );

our @EXPORT_OK = qw( o err );

sub o{
    return Simo::Wrapper->create( obj => $_[0] );
}

sub err{
    return unless $@;
    
    my $err = $@;
    
    my $is_simo_err = eval{ $err->isa( 'Simo::Error' ) };
    my $simo_error = $is_simo_err ? $err : Simo::Error->new( msg => "$err", pos => '' );
    
    $@ = $err;
    return $simo_error;
}

=head1 NAME

Simo::Util - Utility Class for Simo

=head1 VERSION

Version 0.0205

=cut

=head1 DESCRIPTION

Simo::Util is Utitly class for Simo.

This class provide some utility function for Simo.

=cut

=head1 CAUTION

Simo::Util is yet experimental stage.

Please wait until this is stable.

=head1 SYNOPSIS

    use Simo::Util qw( o );
    
    my( $title, $author ) = o($book)->get_values( 'title', 'author' );
    
    my %hash = o($book)->get_hash( 'title', 'author' );
    my $hash_ref = o($book)->get_hash( 'title', 'author' );
    
    o($book)->set_values( title => 'Simple OO', author => 'kimoto' );
    
    use Simo::Util qw( err );
    
    # check error
    if( err ){
        if( err->type eq 'err_type' ){
            my $msg = err->msg;
            my $pos = err->pos;
            my $pkg = err->pkg;
            my $attr = err->attr;
            my $val = err->val;
            
            my $a = err->info->{ a };
            my $b = err->ingo->{ b };
            
            # do something
        }
    }

=head1 EXPORT

By default, no funcion is exported.

All functions can be exported. 

    use Simo::Util qw( o err );

=head1 FUCNTION

=head2 o

o($obj) is equel to Simo::Wrapper->create($obj).

For exsample

    my %hash = o($book)->get_hash( 'title', 'author' );
    
equel to

    my %hash = Simo::Wrapper->create($book)->get_hash( 'title', 'author' );
    
o function is prepare to use Simo::Wrapper object in easy way.

If you know all methods, see L<Simo::Wrapper> document.

Many convenient methods is prepared for a object.

=head2 err

err function convert $@ to Simo::Error object.

If $@ is already Simo::Error object, this function do nothing.

If you accesse $@ using err function, You do not have to distinguish that $@ is string or Simo::Error object.

The following is eneral sample using o function and err function.

new_and_validate method construct objcet and validate its values.
and check error using err function. 

    use Simo::Util( o err );
    
    my $book = eval{
        o('Book')->new_and_validate( 
            { title => 'aaaaaaaaa' },
            { title => sub { length $_ < 5 } }
        );
    };
    
    if( err ){
        if( err->attr eq 'title' ){
            my $type = err->type;
            my $msg = err->msg;
            my $pos = err->pos;
            my $pkg = err->pkg;
            my $val = err->val;
            
            my $a = err->info->{ a };
            my $b = err->ingo->{ b };
            
            # do something
        }
    }

type, msg, pos, pkg, attr,val is accessors of Simo::Error object.

See also L<Simo::Error>

=cut

=head1 AUTHOR

Yuki Kimoto, C<< <kimoto.yuki at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-simo-util at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Simo-Util>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Simo::Util


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Simo-Util>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Simo-Util>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Simo-Util>

=item * Search CPAN

L<http://search.cpan.org/dist/Simo-Util/>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2009 Yuki Kimoto, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Simo::Util
