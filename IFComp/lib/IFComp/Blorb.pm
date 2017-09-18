package IFComp::Blorb;

use warnings;
use strict;

use Exporter 'import';
our @EXPORT_OK = qw( determine_blorb_type );

sub determine_blorb_type {

    # This function borrows code from scanblorb.pl by Graham Nelson and
    # Richard Poole.

    my ($blorb_file) = @_;
    unless ( $blorb_file && $blorb_file->isa('Path::Class::File') ) {
        die "You need to call determine_blorb_type with a "
            . "Path::Class::File object.\n";
    }

    my $blorb_fh = $blorb_file->openr;
    binmode($blorb_fh);

    my $buffer;
    read $blorb_fh, $buffer, 12;

    my ( $groupid, $length, $type ) = unpack( "NNN", $buffer );

    $groupid == 0x464F524D or die "Not a valid FORM file!\n";
    $type == 0x49465253    or die "Not a Blorb file!\n";

    my ( $size, $pos );

    for ( $pos = 12; $pos < $length; $pos += $size + ( $size % 2 ) + 8 ) {
        my $chunkdata;

        read( $blorb_fh, $buffer, 8 ) == 8
            or die("Incomplete chunk header at $pos\n");

        $size = ( unpack( "NN", $buffer ) )[1];    # second word of header
        my $type = substr( $buffer, 0, 4 );

        read( $blorb_fh, $chunkdata, $size ) == $size
            or die("Incomplete chunk at $pos\n");
        if ( $size % 2 ) { read( $blorb_fh, $buffer, 1 ); }

        if ( $type eq 'GLUL' ) {
            return 'inform';
        }
        elsif ( $type eq 'ZCOD' ) {
            return 'inform';
        }
        elsif ( $type eq 'ADRI' ) {
            return 'adrift';
        }
    }

    die
        "$blorb_file is a blorb, but I can't tell what kind of blorb it is.\n";

}

1;
