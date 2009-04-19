use strict;
use warnings;

use Test::More 'no_plan';

package T1;
use Simo;

sub m1{ ac }
sub m2{ ac }
sub m3{ ac }
sub m4{ ac }
sub m5{ ac }

package T2;
use Simo;

sub create{
    return shift->SUPER::new( @_ );
}

sub m1{ ac }
sub m2{ ac }

package main;
use Simo::Util 'set_values_from_xml';


my $t_dir = 't/29-set_values_from_xml';

{
    my $obj = T1->new;
    set_values_from_xml( $obj, "$t_dir/t1.xml" );
    
    is_deeply( $obj, { m1 => 1, m2 => { a => 2, b => 3 }, m3 => 4, m4 => { m1 => 1, m2 => 2 }, m5 => 5 }, 'internal data' );
    isa_ok( $obj, 'T1' );
    isa_ok( $obj->m4, 'T2' );
}

{
    my $obj = T1->new;
    
    my $xml = eval{ set_values_from_xml( $obj, "$t_dir/t2.xml" ) };
    like( $@, qr/t2\.xml/, 'xml error' );
}