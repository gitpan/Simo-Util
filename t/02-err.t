use Test::More 'no_plan';

package main;

use Simo::Util qw( err );
use Simo::Error;
use Carp;

{
    my $err_str = err( type => 'err_type', msg => 'message', a => '1' );
    my $err_str2 = Simo::Error->create_err_str( type => 'err_type', msg => 'message', a => '1' );
    
    is( $err_str, $err_str2, 'err() is Simo::Error->create_err_str()' );
}

{
    eval{
        croak err( type => 'err_type', msg => 'message', a => '1' );
    };

    my $err_obj = err;
    is( $err_obj->type, 'err_type', 'err_obj type' );
    is( $err_obj->msg, 'message', 'err_obj msg' );
    like( $err_obj->pos, qr/ at /, 'err_obj pos' );
    is_deeply( $err_obj->info, { a => 1 }, 'err_obj info' );
}




