package IFComp::Slug;

use strict;
use warnings;
use utf8;

use Exporter qw(import);
use Encode qw(decode FB_CROAK);
use Text::Unidecode;

our @EXPORT_OK = qw(
    title_to_base_slug
    entry_slugs_for_entries
    entry_slugs_for_comp
);

=head1 NAME

IFComp::Slug - URL-friendly slugs for IFComp entries

=head1 DESCRIPTION

Computes deterministic slugs for qualified IFComp entries. Used by the
zip-of-zips builder and comp JSON so archive tools can map filenames to
entry IDs without fuzzy title matching.

=head1 FUNCTIONS

=head2 title_to_base_slug($title)

Returns a URL-friendly slug from an entry title, or C<undef> if nothing
remains after normalization.

=head2 entry_slugs_for_entries(@entries)

Takes entry objects with C<id> and C<title> methods. Returns a hashref
mapping entry ID to final slug.

Entries whose base slugs collide case-insensitively all receive an
C<-{entry_id}> suffix so no bare slug is ambiguous.

=head2 entry_slugs_for_comp($comp)

Convenience wrapper: slugs for all C<is_qualified> entries on a comp.

=cut

sub title_to_base_slug {
    my ($title) = @_;
    return undef unless defined $title && length $title;

    unless ( utf8::is_utf8($title) ) {
        eval {
            # try utf-8 first, but fall back to codepge 1252 if needed
            $title = decode( 'UTF-8', $title, FB_CROAK );
            1;
        } or do {
            $title = decode( 'cp1252', $title );
        };
    }
    $title = unidecode($title);

    $title =~ s/^(?:the|a|an)\s+//i;
    $title =~ s/[^\p{L}\p{N}\s-]//g;
    $title =~ s/\s+/_/g;
    $title =~ s/_+/_/g;
    $title =~ s/^_+|_+$//g;

    return length $title ? $title : undef;
}

sub entry_slugs_for_entries {
    my (@entries) = @_;

    my %base_by_id;
    my %groups;

    for my $entry (@entries) {
        my $id        = $entry->id;
        my $base_slug = title_to_base_slug( $entry->title ) // "entry-$id";
        $base_by_id{$id} = $base_slug;
        push @{ $groups{ lc $base_slug } }, $id;
    }

    my %preferred;
    for my $id ( keys %base_by_id ) {
        my $base_slug = $base_by_id{$id};
        my $group     = $groups{ lc $base_slug };
        $preferred{$id} = ( @$group == 1 ) ? $base_slug : "$base_slug-$id";
    }

    # Claim final slugs in ascending ID order so lower IDs keep a contested
    # name and later entries append -{id} until unique.
    my %used;    # lc(slug) => 1
    my %slugs;
    for my $id ( sort { $a <=> $b } keys %preferred ) {
        my $slug = $preferred{$id};
        while ( $used{ lc $slug } ) {
            $slug = "$slug-$id";
        }
        $used{ lc $slug } = 1;
        $slugs{$id} = $slug;
    }

    return \%slugs;
}

sub entry_slugs_for_comp {
    my ($comp) = @_;
    my @entries = grep { $_->is_qualified } $comp->entries->all;
    return entry_slugs_for_entries(@entries);
}

1;
