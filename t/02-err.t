use Test::More 'no_plan';

package main;

use Simo::Util qw( err );
use Simo::Error;
use Carp;

{
    eval{
        Simo::Error->throw( type => 'err_type', msg => 'message', info => { a => '1' } );
    };

    my $err_obj = err;
    is( $err_obj->type, 'err_type', 'err_obj type' );
    is( $err_obj->msg, 'message', 'err_obj msg' );
    like( $err_obj->pos, qr/ at /, 'err_obj pos' );
    is_deeply( $err_obj->info, { a => 1 }, 'err_obj info' );
    
    my $second_err = err;
    
    my $second_err_obj = err;
    cmp_ok( $err_obj->info, '==', $second_err_obj->info, 'same error' );
    
    $@ = undef;
    
    ok( !err, '$@ is undef' );
    
    $@ = "aaa";
    
    my $no_simo_err = err;
    is_deeply( [ $no_simo_err->type, $no_simo_err->msg, $no_simo_err->pos, $no_simo_err->info ],
               [ 'unknown', 'aaa', '', {} ], 'no Simo::Error' );
}




