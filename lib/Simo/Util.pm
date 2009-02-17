package Simo::Util;

our $VERSION = '0.01_03';

use warnings;
use strict;
use Simo::Wrapper;

use Exporter;
our @ISA = qw( Exporter );

our @EXPORT_OK = qw( o );

sub o{
    return Simo::Wrapper->create( obj => $_[0] );
}

=head1 NAME

Simo::Util - Utility Class for Simo

=head1 VERSION

Version 0.01_03

=cut

=head1 SYNOPSIS

    use Simo::Util qw( o );
    
    my( $title, $author ) = o($book)->get_attrs( 'title', 'author' );
    
    my %hash = o($book)->get_attrs_as_hash( 'title', 'author' );
    my $hash_ref = o($book)->get_attrs_as_hash( 'title', 'author' );
    
    o($book)->set_attrs( title => 'Simple OO', author => 'kimoto' );
    
    my $result = o($book_list)->run_methods(
        'select' => [ type => 'Commic' ],
        'sort' => [ 'desc' ],
        'get_result'
    );

=head1 EXPORT

By default, no funcion is exported.

All functions can be exported. 

    use Simo::Util qw( o );

=head1 o() functions

o() is object wrapper.

wrapped object use useful methods provided by Simo::Wrapper.

=head1 Simo::Wrapper methods

=head2 get_attrs

You can get multiple attrs value.

    my( $title, $author ) = o($book)->get_attrs( 'title', 'author' );

=head2 get_attrs_as_hash

You can get multiple attrs value as hash or hash ref.

    my %hash = o($book)->get_attrs_as_hash( 'title', 'author' );

or

    my $hash_ref = o($book)->get_attrs_as_hash( 'title', 'author' );

=head2 set_attrs

You can set multiple attrs valule.

    o($book)->set_attrs( title => 'Simple OO', author => 'kimoto' );
    
This method return wrapped object. so you can call method continuous.

    o($book)->set_attrs( title => 'good news' )->run_methods( 'sort' );

=head2 run_methods

This run some methods continuous.

    my $result = o($book_list)->run_methods(
        'select' => [ type => 'Commic' ],
        'sort' => [ 'desc' ],
        'get_result'
    );
    
Method args must be array ref. Please be carefull not to specify scalar or list.

    my $result = o($book_list)->run_methods(
        'select' => ( type => 'Commic' ), # this is not work.
        'sort' => 'desc', # this is also not work.
    );

You can omit args.

    my $result = o($book_list)->run_methods(
        'get_result' # omit args
    );

You can get last method return value.

=head2 new


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


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Yuki Kimoto, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Simo::Util
