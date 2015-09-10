package TestORM;
use parent 'SORM';
use IO::Uncompress::Inflate qw(inflate $InflateError);
use IO::Compress::Deflate qw(deflate $DeflateError);
use JSON::XS ();


__PACKAGE__->meta({
    master_table => {
        id => { type => 'bigint', nullable => 0, primary_key => 1 },
        data => { type => 'jsont' },
    },
    slave_table => {
        id => { type => 'bigint', nullable => 0, primary_key => 1 },
        master_id => { type => 'bigint', references => 'master_table' },
        slave_data => { type => 'text' },
    }
});

__PACKAGE__->additional_column_types({
    jsonp => {
        inflate => sub {
            my ($query, $data) = @_;
            my $str = '';
            unless (inflate(\$data, \$str)) {
                die "Can't inflate string: $InflateError";
            }

            $data = JSON::XS::decode_json($str);
            if ($@) {
                die "decode_json failture: $@"
            }
            return $data;
        },
        deflate => sub {
            my ($query, $data) = @_;
        }
    },
    jsont => {
        inflate => sub {
            my ($query, $data) = @_;
            return JSON::XS::decode_json($data);
        }
    }
});
1;
