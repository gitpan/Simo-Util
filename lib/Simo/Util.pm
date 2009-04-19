package Simo::Util;

our $VERSION = '0.0301';

use warnings;
use strict;
use Carp;
use Simo::Constrain qw( is_object is_class_name );
use Simo::Error;

use Exporter;
our @ISA = qw( Exporter );

our @EXPORT_OK = qw( o err run_methods encode_attrs clone freeze thaw validate
                     new_and_validate new_from_objective_hash new_from_xml
                     get_hash get_values set_values encode_values decode_values
                     filter_values set_values_from_objective_hash
                     set_values_from_xml define_class define_class );

sub err{
    return unless $@;
    
    my $err = $@;
    
    my $is_simo_err = eval{ $err->isa( 'Simo::Error' ) };
    my $simo_error = $is_simo_err ? $err : Simo::Error->new( msg => "$err", pos => '' );
    
    $@ = $err;
    return $simo_error;
}

sub validate{
    my ( $obj, @args ) = @_;
    my $pkg = ref $obj;
    croak "Cannot call 'validate' from class" unless $pkg;
    
    # check args
    @args = %{ $args[0] } if ref $args[0] eq 'HASH';
    croak "key-value pairs must be passed to 'validate'" if @args % 2;
    
    # set args
    while( my ( $attr, $validator ) = splice( @args, 0, 2 ) ){
        croak "Attr '$attr' is not exist" unless $obj->can( $attr );
        croak "Value must be code reference" unless ref $validator eq 'CODE';
        
        local $_ = $obj->$attr;
        my $info = {};
        my $ret = $validator->( $_, $info );
        if( !$ret ){
            Simo::Error->throw( 
                type => 'value_invalid',
                msg => "${pkg}::$attr must be valid value",
                pkg => $pkg,
                attr => $attr,
                val => $_,
                info => $info
            );
        }
    }
    return 1;
}

# new object and validate
sub new_and_validate{
    my ( $invocant, @args ) = @_;
    
    my $class = ref $invocant || $invocant;
    croak "Cannot call new form $class." unless $class->can( 'new' );
    
    if( ref $args[0] eq 'HASH' && ref $args[0] eq 'HASH' ){
        my $always_valid = sub{ 1 };
        foreach my $attr ( keys %{ $args[0] } ){
            $args[1]->{ $attr } = $always_valid unless exists $args[1]->{ $attr }
        }
        
        local $Carp::CarpLevel += 1;
        my $obj = $invocant->new( $args[0] );
        validate( $obj, $args[1] );
        return $obj;
    }
    else{
        croak "key-value-validator pairs must be passed to 'new_and_validate'."
            if @args % 3;
        
        my @key_value_pairs;
        my @key_validator_pairs;
        while( my ( $key, $val, $validator ) = splice( @args, 0, 3 ) ){
            push @key_value_pairs, $key, $val;
            push @key_validator_pairs, $key, $validator;
        }
        
        local $Carp::CarpLevel += 1;
        my $obj = $invocant->new( @key_value_pairs );
        validate( $obj, @key_validator_pairs );
        return $obj;
    }
}

sub new_from_objective_hash{
    my ( $obj, @args ) = @_;
    
    # check args
    @args = %{ $args[0] } if ref $args[0] eq 'HASH';
    croak "key-value pairs must be passed to 'new_from_objective_hash'." if @args % 2;
    my %args = @args;
    
    my $class = ref $obj || $obj;
    if( !$class || $class eq 'Simo' ){
        $class = $args{ __CLASS };
    }
    delete $args{ __CLASS };
    
    my $constructor = delete $args{ __CLASS_CONSTRUCTOR } || 'new';
    
    while( my ( $attr, $val ) = each %args ){
        if( ref $args{ $attr } eq 'HASH' && $args{ $attr }->{ __CLASS } ){
            $val = new_from_objective_hash( undef, $args{ $attr } );
        }
        $args{ $attr } = $val;
    }

    eval "require $class";
    {
        croak "'$class' do not have '$constructor' method." unless $class->can( $constructor );
        no strict 'refs';
        
        local $Carp::CarpLevel += 1;
        $obj = $class->$constructor( %args );
    }
    return $obj;
}

sub new_from_xml{
    my ( $obj, $xml ) = @_;
    require XML::Simple;
    
    my $objective_hash;
    {
        local $SIG{ __WARN__ } = sub{};
        $objective_hash = eval{ XML::Simple->new->XMLin( $xml ) };
        croak "$@ in $xml" if $@;
    }
    
    
    local $Carp::CarpLevel += 1;
    return new_from_objective_hash( $obj, $objective_hash );
}

# get value specify attr names
sub get_values{
    my ( $obj, @attrs ) = @_;
    
    croak "'get_values' must be called from object." unless is_object( $obj );
    
    @attrs = @{ $attrs[0] } if ref $attrs[0] eq 'ARRAY';
    
    my @vals;
    foreach my $attr ( @attrs ){
        croak "Invalid key '$attr' is passed to get_values" unless $obj->can( $attr );
        
        local $Carp::CarpLevel += 1;
        my $val = $obj->$attr;
        push @vals, $val;
    }
    wantarray ? @vals : $vals[0];
}

# get value as hash specify attr names
sub get_hash{
    my ( $obj, @attrs ) = @_;
    
    croak "'get_hash' must be called from object." unless is_object( $obj );
    
    local $Carp::CarpLevel += 1;
    my @vals = get_values( $obj, @attrs );
    
    my %values;
    @values{ @attrs } = @vals;
    
    return \%values;
}

# set values
sub set_values{
    my ( $obj, @args ) = @_;
    
    croak "'set_values' must be called from object." unless is_object( $obj );
    
    # check args
    @args = %{ $args[0] } if ref $args[0] eq 'HASH';
    croak "key-value pairs must be passed to 'set_values'." if @args % 2;
    
    # set args
    while( my ( $attr, $val ) = splice( @args, 0, 2 ) ){
        croak "Invalid key '$attr' is passed to 'set_values'" unless $obj->can( $attr );
        no strict 'refs';
        local $Carp::CarpLevel += 1;
        $obj->$attr( $val );
    }
    return 1;
}


# set values
sub set_values_from_objective_hash{
    my ( $obj, @args ) = @_;
    
    croak "'set_values_from_objective_hash' must be called from object." unless is_object( $obj );
    
    # check args
    @args = %{ $args[0] } if ref $args[0] eq 'HASH';
    croak "key-value pairs must be passed to 'set_values_from_objective_hash'" if @args % 2;
    
    # set args
    my %args = @args;
    while( my ( $attr, $val ) = each %args ){
        if( $attr eq '__CLASS' || $attr eq '__CLASS_CONSTRUCTOR' ){
            delete $args{ $attr };
            next;
        }
        
        croak "Invalid key '$attr' is passed to 'set_values_from_objective_hash'" unless $obj->can( $attr );
        if( ref $args{ $attr } eq 'HASH' && $args{ $attr }->{ __CLASS } ){
            $val = new_from_objective_hash( undef, $args{ $attr } );
        }
        no strict 'refs';
        local $Carp::CarpLevel += 1;
        $obj->$attr( $val );
    }
    return 1;
}

sub set_values_from_xml{
    my ( $obj, $xml ) = @_;
    require XML::Simple;
    
    my $objective_hash;
    {
        local $SIG{ __WARN__ } = sub{};
        $objective_hash = eval{ XML::Simple->new->XMLin( $xml ) };
        croak "$@ in $xml" if $@;
    }
    set_values_from_objective_hash( $obj, $objective_hash );
    return 1;
}

# run methods
sub run_methods{
    my ( $obj, @method_or_args_list ) = @_;
    
    croak "'run_methods' must be called from object." unless is_object( $obj );
    
    my $method_infos = _parse_run_methods_args( $obj, @method_or_args_list );
    while( my $method_info = shift @{ $method_infos } ){
        my ( $method, $args ) = @{ $method_info }{ qw( name args ) };
        
        local $Carp::CarpLevel += 1;
        if( @{ $method_infos } ){
            $obj->$method( @{ $args } );
        }
        else{
            return wantarray ? ( $obj->$method( @{ $args } ) ) :
                                 $obj->$method( @{ $args } );
        }
    }
}
{
    no warnings 'once';
    *call = \&run_methods;
}
sub _parse_run_methods_args{
    my ( $obj, @method_or_args_list ) = @_;
    
    my $method_infos = [];
    while( my $method_or_args = shift @method_or_args_list ){
        croak "$method_or_args is bad. Method name must be string and args must be array ref"
            if ref $method_or_args;
        
        my $method = $method_or_args;
        croak "$method is not exist" unless $obj->can( $method );
        
        my $method_info = {};
        $method_info->{ name } = $method;
        $method_info->{ args } = ref $method_or_args_list[0] eq 'ARRAY' ?
                                 shift @method_or_args_list :
                                 [];
        
        push @{ $method_infos }, $method_info;
    }
    return $method_infos;
}

sub filter_values{
    my ( $obj, $code, @attrs ) = @_;
    
    croak "'filter_values' must be called from object." unless is_object( $obj );
    
    croak "First argument must be code reference." unless ref $code eq 'CODE';
    
    foreach my $attr ( @attrs ){
        croak "'$attr' is not exist." unless $obj->can( $attr );
        
        $obj->$attr unless exists $obj->{ $attr }; # initialized if attr is not called yet.
        
        if( ref $obj->{ $attr } eq 'ARRAY' ){
            foreach my $i ( 0 .. @{ $obj->{ $attr } } - 1 ){
                my $info = { type => 'ARRAY', attr => $attr, index => $i, self => $obj };
                
                $obj->{ $attr }[ $i ] = $code->( $obj->{ $attr }[ $i ], $info );
            }
        }
        elsif( ref $obj->{ $attr } eq 'HASH' ){
            foreach my $key ( keys %{ $obj->{ $attr } } ){
                my $info = { type => 'HASH', attr => $attr, key => $key, self => $obj };
                
                $obj->{ $attr }{ $key } = $code->( $obj->{ $attr }{ $key }, $info );
            }
        }
        else{
            my $info = { type => 'SCALAR', attr => $attr, self => $obj };
            $obj->{ $attr } = $code->( $obj->{ $attr }, $info );
        }
    }
}

sub encode_values{
    my ( $obj, $encoding, @attrs ) = @_;
    
    croak "'encode_values' must be called from object." unless is_object( $obj );
    
    require Encode;
    filter_values(
        $obj,
        sub{
            my ( $val, $info ) = @_;
            
            my ( $type, $attr ) = @{ $info }{ qw( type attr ) };
            
            if( ref $val ){
                my $warn = $type eq 'ARRAY'  ? "\$self->{ '$attr' }[ $info->{ index } ] must be string. Encode is not done." :
                           $type eq 'HASH'   ? "\$self->{ '$attr' }{ '$info->{ key }' } must be string. Encode is not done." :
                           $type eq 'SCALAR' ? "\$self->{ '$attr' } must be string or array ref or hash ref. Encode is not done." :
                           '';
                carp $warn;
                return $val;
            }
            return Encode::encode( $encoding, $val );
        },
        @attrs
    );
}

sub decode_values{
    my ( $obj, $encoding, @attrs ) = @_;
    
    croak "'decode_values' must be called from object." unless is_object( $obj );
    
    require Encode;
    filter_values(
        $obj,
        sub{
            my ( $val, $info ) = @_;
            
            my ( $type, $attr ) = @{ $info }{ qw( type attr ) };
            
            if( ref $val ){
                my $warn = $type eq 'ARRAY'  ? "\$self->{ '$attr' }[ $info->{ index } ] must be string. Decode is not done." :
                           $type eq 'HASH'   ? "\$self->{ '$attr' }{ '$info->{ key }' } must be string. Decode is not done." :
                           $type eq 'SCALAR' ? "\$self->{ '$attr' } must be string or array ref or hash ref. Decode is not done." :
                           '';
                carp $warn;
                return $val;
            }
            return Encode::decode( $encoding, $val );
        },
        @attrs
    );
}

sub clone{
    my $obj = shift;;
    
    croak "'clone' must be called from object." unless is_object( $obj );
    
    require Storable;
    return Storable::dclone( $obj );
}

sub freeze{
    my $obj = shift;
    
    croak "'freeze' must be called from object." unless is_object( $obj );
    
    require Storable;
    return Storable::freeze( $obj );
}

sub thaw{
    my ( $class, $freezed ) = @_;
    
    require Storable;
    return Storable::thaw( $freezed );
}

sub define_class{
    my ( $class, @accessors ) = @_;
    
    croak "'define_class' must be called from class name. '$class' is bad."
        unless is_class_name( $class );
    
    my $e .=
        qq/package $class;\n/ .
        qq/use Simo;\n\n/;
    
    foreach my $accessor ( @accessors ){
        croak "accessor must be method name. '$accessor' is bad."
            unless $accessor =~ /^[a-zA-Z]\w*$/;
        
        $e .=
        qq/sub $accessor { ac }\n/;
    }
    
    $e .=
        qq/1;\n/;
    
    eval $e;
    croak $@ if $@; # never ocurred
}

# o is now not recommend. don't use this
sub o{
    require Simo::Wrapper;
    return Simo::Wrapper->create( obj => $_[0] );
}


=head1 NAME

Simo::Util - Utility Class for Simo

=head1 VERSION

Version 0.0301

=cut

=head1 DESCRIPTION

Simo::Util is Utitly class for Simo.

This class provide some utility function for Simo.

=cut

=head1 CAUTION

Simo::Util is yet experimental stage.

Please wait until this is stable.

=head1 SYNOPSIS

    use Simo::Util qw( get_values get_hash set_values );
    
    my( $title, $author ) = get_values( $book, 'title', 'author' );
    
    my %hash = get_hash( $book, 'title', 'author' );
    my $hash_ref = get_hash( $book, 'title', 'author' );
    
    set_values( $book, title => 'Simple OO', author => 'kimoto' );
    
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

    use Simo::Util qw( get_values get_hash set_values );

=head1 FUCNTION

=head2 err

err function convert $@ to Simo::Error object.

If $@ is already Simo::Error object, this function do nothing.

If you accesse $@ using err function, You do not have to distinguish that $@ is string or Simo::Error object.

The following is eneral sample using o function and err function.

new_and_validate method construct objcet and validate its values.
and check error using err function. 

    use Simo::Util( o err );
    
    my $book = eval{
        new_and_validate(
            'Book',
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

=head2 validate

'validate' is the method for validating.

    my $book = Book->new( title => 'Good time', price => 3000);
    validate(
        $book,
        title => sub{ length $_ < 30 },
        prcie => sub{ $_ > 0 && $_ < 3000 }
    );

If validator function return false value, 'validate' throw L<Simo::Error> object.

'value_invalid' is set to 'type' field of L<Simo::Error> object.

=head2 new_and_validate

'new_and_validate' construct object and validate object.

You can use 2 type of argument.

First: key-value-validator

    my $book = new_and_validate(
        'Book',
        title => 'a', sub{ length $_ < 30 },
        price => 1000, sub{ $_ > 0 && $_ < 50000 },
        auhtor => 'Kimoto', sub{ 1 }
    );
    
If you do not validate some field, you pass sub{ 1 } to validator.

Second: { key => value }, { key => validator }

    my $book = new_and_validate(
        'Book',
        { title => 'a', price => 'b' },
        { title=> sub{ length $_ < 30 }, price => sub{ $_ > 0 && $_ < 50000 } }
    );

This method return constructed object.

=head2 define_class

'define_class' define class having some accessors.

    define_class( 'Book', qw/title author/ );

You can use Book class after this.

    my $book = Book->new( title => 'Good news', author => 'Kimoto' );

=head2 get_values

'get_values' get the values.

    my ( $title, $author ) = get_values( $book, qw/ title author / );

=head2 get_hash

'get_hash' get the hash of specified fields.
    
    my $book = Book->new( title => 'Good cat', author => 'Kimoto', price => 3000 );
    my $hash = get_hash( $book, qw/ title author / );

$hash is that

    {
        title => 'Good cat',
        auhtor => 'Kimoto'
    }

=head2 set_values

'set_values' set values of the object.

    set_values( $book, title => 'Good news', author => 'kimoto' );

You can also pass hash reference

    set_values( $book, { title => 'Good news', author => 'kimoto' } );

=head2 new_from_objective_hash

'new_from_objective_hash' construct object from a I<objective hash>.

    my $book = new_from_objective_hash( undef, $objective_hash );

You maybe hear the name of I<objective hash> at first.

I<objective hash> is the hash that contain the information of object accroding to the following rules.

=over 4

=item 1. '__CLASS' is class name.

=item 2. '__CLASS_CONSTRUCTOR' is object constructor name. If this is ommited, 'new' is used as constructor name.

=back

objective hash sample is

    my $objective_hash = { 
        __CLASS => 'Book',
        __CLASS_CONSTRUCTOR => 'new',
        
        title => 'Good thing',
        
        author => {
            __CLASS => 'Person',
            
            name => 'Kimoto',
            age => 19,
            country => 'Japan'
        },
        
        price => 2600
    };

'Person' object is automatically constructed and set to 'author' field.

After that, 'Book' object is constructed .

=head2 new_from_xml

'new_from_xml' construct object from a XML file.

    my $book = new_from_xml( undef, $xml_file );

XML file sample is

    <?xml version="1.0" encoding='UTF-8' ?>
    <root __CLASS="Book" >
      <title>Good man</title>
      
      <author __CLASS="Person">
        <name>Kimoto</name>
        <age>28</age>
        <country>Japan</country>
      </author>
    </root>

You can use the xml using the form of objective hash.
See also 'new_from_objective_hash'.

The xml parser of this method is 'XML::Simple'.
See also L<XML::Simple>

=head2 set_values_from_objective_hash

'set_values_from_objective_hash' set values from a I<objective hash>.

    set_values_from_objective_hash( $book, $objective_hash );

See also 'new_from_objective_hash'.

=head2 set_values_from_xml

'set_values_from_xml' set values loading from XML file.

    set_values_from_xml( $book, $xml_file );
    
You can use the xml using the form of objective hash.
See also 'new_from_objective_hash'.

The xml parser of this method is 'XML::Simple'.
See also L<XML::Simple>

=head2 run_methods

'run_methods' call multiple methods.

    my $result = run_methods(
        $book_list,
        find => [ 'author' => 'kimoto' ],
        sort => [ 'price', 'desc' ],
        'get_result'
    );

This method return the return value of last method
( this example, retrun value of 'get_result' )

=head2 call

'call' is aliase of 'run_methods'

=head2 filter_values

'filter_values' convert multiple values.
    
    filter_values( $book, sub{ uc $_ }, qw/ title author / );

$book->title and $book->author is converted to upper case.
    
This method also filter the values of array ref.

    $book->author( [ 'Kimoto', 'Matuda' ] );
    filter_values( $book, sub{ uc $_ }, qw/ author / );

'Kimoto' and 'Matuda' is converted to upper case.

This method also filter the values of hash ref.

    $book->info( { country => 'Japan', quality => 'Good' } );
    filter_values( $book, sub{ uc $_ }, qw/ info / );

'Japan' and 'Good' is converted to upper case.

These 'filter_values' logic is used by 'encode_values' and 'decode_values'.

=head2 encode_values

'encode_values' encode multiple values.

    encode_values( $book, 'utf8', qw/ title author / );

$book->title and $book->author is encoded.

This method also encode the values of array ref.

    $book->author( [ 'Kimoto', 'Matuda' ] );
    encode_values( $book, 'utf8', qw/ author / );

'Kimoto' and 'Matuda' is encoded.

This method also encode the values of hash ref.

    $book->info( { country => 'Japan', quality => 'Good' } );
    encode_values( $book, 'utf8', qw/ info / );

'Japan' and 'Good' is encoded.

=head2 decode_values

'decode_values' decode multipul values.

    decode_values( $book, 'utf8', qw/ title author / );

$book->title and $book->author is decoded.

This method also decode the values of array ref.

    $book->author( [ 'Kimoto', 'Matuda' ] );
    decode_values( $book, 'utf8', qw/ author / );

'Kimoto' and 'Matuda' is decoded.

This method also decode the values of hash ref.

    $book->info( { country => 'Japan', quality => 'Good' } );
    decode_values( $book, 'utf8', qw/ info / );

'Japan' and 'Good' is decoded.

=head2 clone

'clone' copy the object deeply.

    my $book_copy = clone( $book );

'clone' is the same as Storable::clone.
See also L<Storable>

=head2 freeze

'freeze' serialize the object.

    my $book_freezed = freeze( $book );

'freeze' is the same as Storable::freeze.
See also L<Storable>

=head2 thaw

'thaw' resotre the freezed object.

    my $book = thaw( undef, $book_freezed );

'thaw' is the same as Storable::thaw.
See also L<Storable>

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
