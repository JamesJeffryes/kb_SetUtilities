package kb_util_dylan::kb_util_dylanClient;

use JSON::RPC::Client;
use POSIX;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
my $get_time = sub { time, 0 };
eval {
    require Time::HiRes;
    $get_time = sub { Time::HiRes::gettimeofday() };
};

use Bio::KBase::AuthToken;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

kb_util_dylan::kb_util_dylanClient

=head1 DESCRIPTION


** A KBase module: kb_util_dylan
**
** This module contains basic utilities


=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => kb_util_dylan::kb_util_dylanClient::RpcClient->new,
	url => $url,
	headers => [],
    };

    chomp($self->{hostname} = `hostname`);
    $self->{hostname} ||= 'unknown-host';

    #
    # Set up for propagating KBRPC_TAG and KBRPC_METADATA environment variables through
    # to invoked services. If these values are not set, we create a new tag
    # and a metadata field with basic information about the invoking script.
    #
    if ($ENV{KBRPC_TAG})
    {
	$self->{kbrpc_tag} = $ENV{KBRPC_TAG};
    }
    else
    {
	my ($t, $us) = &$get_time();
	$us = sprintf("%06d", $us);
	my $ts = strftime("%Y-%m-%dT%H:%M:%S.${us}Z", gmtime $t);
	$self->{kbrpc_tag} = "C:$0:$self->{hostname}:$$:$ts";
    }
    push(@{$self->{headers}}, 'Kbrpc-Tag', $self->{kbrpc_tag});

    if ($ENV{KBRPC_METADATA})
    {
	$self->{kbrpc_metadata} = $ENV{KBRPC_METADATA};
	push(@{$self->{headers}}, 'Kbrpc-Metadata', $self->{kbrpc_metadata});
    }

    if ($ENV{KBRPC_ERROR_DEST})
    {
	$self->{kbrpc_error_dest} = $ENV{KBRPC_ERROR_DEST};
	push(@{$self->{headers}}, 'Kbrpc-Errordest', $self->{kbrpc_error_dest});
    }

    #
    # This module requires authentication.
    #
    # We create an auth token, passing through the arguments that we were (hopefully) given.

    {
	my $token = Bio::KBase::AuthToken->new(@args);
	
	if (!$token->error_message)
	{
	    $self->{token} = $token->token;
	    $self->{client}->{token} = $token->token;
	}
        else
        {
	    #
	    # All methods in this module require authentication. In this case, if we
	    # don't have a token, we can't continue.
	    #
	    die "Authentication failed: " . $token->error_message;
	}
    }

    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 KButil_FASTQ_to_FASTA

  $return = $obj->KButil_FASTQ_to_FASTA($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a kb_util_dylan.KButil_FASTQ_to_FASTA_Params
$return is a kb_util_dylan.KButil_FASTQ_to_FASTA_Output
KButil_FASTQ_to_FASTA_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_ref has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
KButil_FASTQ_to_FASTA_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

$params is a kb_util_dylan.KButil_FASTQ_to_FASTA_Params
$return is a kb_util_dylan.KButil_FASTQ_to_FASTA_Output
KButil_FASTQ_to_FASTA_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_ref has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
KButil_FASTQ_to_FASTA_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=item Description



=back

=cut

 sub KButil_FASTQ_to_FASTA
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function KButil_FASTQ_to_FASTA (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to KButil_FASTQ_to_FASTA:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'KButil_FASTQ_to_FASTA');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "kb_util_dylan.KButil_FASTQ_to_FASTA",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'KButil_FASTQ_to_FASTA',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method KButil_FASTQ_to_FASTA",
					    status_line => $self->{client}->status_line,
					    method_name => 'KButil_FASTQ_to_FASTA',
				       );
    }
}
 


=head2 KButil_Merge_FeatureSet_Collection

  $return = $obj->KButil_Merge_FeatureSet_Collection($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a kb_util_dylan.KButil_Merge_FeatureSet_Collection_Params
$return is a kb_util_dylan.KButil_Merge_FeatureSet_Collection_Output
KButil_Merge_FeatureSet_Collection_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_refs has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
	desc has a value which is a string
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
KButil_Merge_FeatureSet_Collection_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

$params is a kb_util_dylan.KButil_Merge_FeatureSet_Collection_Params
$return is a kb_util_dylan.KButil_Merge_FeatureSet_Collection_Output
KButil_Merge_FeatureSet_Collection_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_refs has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
	desc has a value which is a string
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
KButil_Merge_FeatureSet_Collection_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=item Description



=back

=cut

 sub KButil_Merge_FeatureSet_Collection
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function KButil_Merge_FeatureSet_Collection (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to KButil_Merge_FeatureSet_Collection:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'KButil_Merge_FeatureSet_Collection');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "kb_util_dylan.KButil_Merge_FeatureSet_Collection",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'KButil_Merge_FeatureSet_Collection',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method KButil_Merge_FeatureSet_Collection",
					    status_line => $self->{client}->status_line,
					    method_name => 'KButil_Merge_FeatureSet_Collection',
				       );
    }
}
 


=head2 KButil_Merge_GenomeSets

  $return = $obj->KButil_Merge_GenomeSets($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a kb_util_dylan.KButil_Merge_GenomeSets_Params
$return is a kb_util_dylan.KButil_Merge_GenomeSets_Output
KButil_Merge_GenomeSets_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_refs has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
	desc has a value which is a string
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
KButil_Merge_GenomeSets_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

$params is a kb_util_dylan.KButil_Merge_GenomeSets_Params
$return is a kb_util_dylan.KButil_Merge_GenomeSets_Output
KButil_Merge_GenomeSets_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_refs has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
	desc has a value which is a string
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
KButil_Merge_GenomeSets_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=item Description



=back

=cut

 sub KButil_Merge_GenomeSets
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function KButil_Merge_GenomeSets (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to KButil_Merge_GenomeSets:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'KButil_Merge_GenomeSets');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "kb_util_dylan.KButil_Merge_GenomeSets",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'KButil_Merge_GenomeSets',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method KButil_Merge_GenomeSets",
					    status_line => $self->{client}->status_line,
					    method_name => 'KButil_Merge_GenomeSets',
				       );
    }
}
 


=head2 KButil_Build_GenomeSet

  $return = $obj->KButil_Build_GenomeSet($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a kb_util_dylan.KButil_Build_GenomeSet_Params
$return is a kb_util_dylan.KButil_Build_GenomeSet_Output
KButil_Build_GenomeSet_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_refs has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
	desc has a value which is a string
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
KButil_Build_GenomeSet_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

$params is a kb_util_dylan.KButil_Build_GenomeSet_Params
$return is a kb_util_dylan.KButil_Build_GenomeSet_Output
KButil_Build_GenomeSet_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_refs has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
	desc has a value which is a string
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
KButil_Build_GenomeSet_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=item Description



=back

=cut

 sub KButil_Build_GenomeSet
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function KButil_Build_GenomeSet (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to KButil_Build_GenomeSet:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'KButil_Build_GenomeSet');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "kb_util_dylan.KButil_Build_GenomeSet",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'KButil_Build_GenomeSet',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method KButil_Build_GenomeSet",
					    status_line => $self->{client}->status_line,
					    method_name => 'KButil_Build_GenomeSet',
				       );
    }
}
 


=head2 KButil_Build_GenomeSet_from_FeatureSet

  $return = $obj->KButil_Build_GenomeSet_from_FeatureSet($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a kb_util_dylan.KButil_Build_GenomeSet_from_FeatureSet_Params
$return is a kb_util_dylan.KButil_Build_GenomeSet_from_FeatureSet_Output
KButil_Build_GenomeSet_from_FeatureSet_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_ref has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
	desc has a value which is a string
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
KButil_Build_GenomeSet_from_FeatureSet_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

$params is a kb_util_dylan.KButil_Build_GenomeSet_from_FeatureSet_Params
$return is a kb_util_dylan.KButil_Build_GenomeSet_from_FeatureSet_Output
KButil_Build_GenomeSet_from_FeatureSet_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_ref has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
	desc has a value which is a string
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
KButil_Build_GenomeSet_from_FeatureSet_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=item Description



=back

=cut

 sub KButil_Build_GenomeSet_from_FeatureSet
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function KButil_Build_GenomeSet_from_FeatureSet (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to KButil_Build_GenomeSet_from_FeatureSet:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'KButil_Build_GenomeSet_from_FeatureSet');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "kb_util_dylan.KButil_Build_GenomeSet_from_FeatureSet",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'KButil_Build_GenomeSet_from_FeatureSet',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method KButil_Build_GenomeSet_from_FeatureSet",
					    status_line => $self->{client}->status_line,
					    method_name => 'KButil_Build_GenomeSet_from_FeatureSet',
				       );
    }
}
 


=head2 KButil_Add_Genomes_to_GenomeSet

  $return = $obj->KButil_Add_Genomes_to_GenomeSet($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a kb_util_dylan.KButil_Add_Genomes_to_GenomeSet_Params
$return is a kb_util_dylan.KButil_Add_Genomes_to_GenomeSet_Output
KButil_Add_Genomes_to_GenomeSet_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_genome_refs has a value which is a kb_util_dylan.data_obj_ref
	input_genomeset_ref has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
	desc has a value which is a string
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
KButil_Add_Genomes_to_GenomeSet_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

$params is a kb_util_dylan.KButil_Add_Genomes_to_GenomeSet_Params
$return is a kb_util_dylan.KButil_Add_Genomes_to_GenomeSet_Output
KButil_Add_Genomes_to_GenomeSet_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_genome_refs has a value which is a kb_util_dylan.data_obj_ref
	input_genomeset_ref has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
	desc has a value which is a string
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
KButil_Add_Genomes_to_GenomeSet_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=item Description



=back

=cut

 sub KButil_Add_Genomes_to_GenomeSet
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function KButil_Add_Genomes_to_GenomeSet (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to KButil_Add_Genomes_to_GenomeSet:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'KButil_Add_Genomes_to_GenomeSet');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "kb_util_dylan.KButil_Add_Genomes_to_GenomeSet",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'KButil_Add_Genomes_to_GenomeSet',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method KButil_Add_Genomes_to_GenomeSet",
					    status_line => $self->{client}->status_line,
					    method_name => 'KButil_Add_Genomes_to_GenomeSet',
				       );
    }
}
 


=head2 KButil_Concat_MSAs

  $return = $obj->KButil_Concat_MSAs($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a kb_util_dylan.KButil_Concat_MSAs_Params
$return is a kb_util_dylan.KButil_Concat_MSAs_Output
KButil_Concat_MSAs_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_refs has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
	desc has a value which is a string
	blanks_flag has a value which is a kb_util_dylan.bool
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
bool is an int
KButil_Concat_MSAs_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

$params is a kb_util_dylan.KButil_Concat_MSAs_Params
$return is a kb_util_dylan.KButil_Concat_MSAs_Output
KButil_Concat_MSAs_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_refs has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
	desc has a value which is a string
	blanks_flag has a value which is a kb_util_dylan.bool
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
bool is an int
KButil_Concat_MSAs_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=item Description



=back

=cut

 sub KButil_Concat_MSAs
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function KButil_Concat_MSAs (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to KButil_Concat_MSAs:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'KButil_Concat_MSAs');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "kb_util_dylan.KButil_Concat_MSAs",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'KButil_Concat_MSAs',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method KButil_Concat_MSAs",
					    status_line => $self->{client}->status_line,
					    method_name => 'KButil_Concat_MSAs',
				       );
    }
}
 


=head2 KButil_Split_Reads

  $return = $obj->KButil_Split_Reads($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a kb_util_dylan.KButil_Split_Reads_Params
$return is a kb_util_dylan.KButil_Split_Reads_Output
KButil_Split_Reads_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_ref has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
	split_num has a value which is an int
	desc has a value which is a string
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
KButil_Split_Reads_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

$params is a kb_util_dylan.KButil_Split_Reads_Params
$return is a kb_util_dylan.KButil_Split_Reads_Output
KButil_Split_Reads_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_ref has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
	split_num has a value which is an int
	desc has a value which is a string
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
KButil_Split_Reads_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=item Description



=back

=cut

 sub KButil_Split_Reads
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function KButil_Split_Reads (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to KButil_Split_Reads:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'KButil_Split_Reads');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "kb_util_dylan.KButil_Split_Reads",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'KButil_Split_Reads',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method KButil_Split_Reads",
					    status_line => $self->{client}->status_line,
					    method_name => 'KButil_Split_Reads',
				       );
    }
}
 


=head2 KButil_Random_Subsample_Reads

  $return = $obj->KButil_Random_Subsample_Reads($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a kb_util_dylan.KButil_Random_Subsample_Reads_Params
$return is a kb_util_dylan.KButil_Random_Subsample_Reads_Output
KButil_Random_Subsample_Reads_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_ref has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
	subsample_fraction has a value which is a kb_util_dylan.Fractionate_Options
	desc has a value which is a string
	seed has a value which is an int
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
Fractionate_Options is a reference to a hash where the following keys are defined:
	split_num has a value which is an int
	reads_num has a value which is an int
	reads_perc has a value which is a float
KButil_Random_Subsample_Reads_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

$params is a kb_util_dylan.KButil_Random_Subsample_Reads_Params
$return is a kb_util_dylan.KButil_Random_Subsample_Reads_Output
KButil_Random_Subsample_Reads_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_ref has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
	subsample_fraction has a value which is a kb_util_dylan.Fractionate_Options
	desc has a value which is a string
	seed has a value which is an int
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
Fractionate_Options is a reference to a hash where the following keys are defined:
	split_num has a value which is an int
	reads_num has a value which is an int
	reads_perc has a value which is a float
KButil_Random_Subsample_Reads_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=item Description



=back

=cut

 sub KButil_Random_Subsample_Reads
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function KButil_Random_Subsample_Reads (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to KButil_Random_Subsample_Reads:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'KButil_Random_Subsample_Reads');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "kb_util_dylan.KButil_Random_Subsample_Reads",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'KButil_Random_Subsample_Reads',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method KButil_Random_Subsample_Reads",
					    status_line => $self->{client}->status_line,
					    method_name => 'KButil_Random_Subsample_Reads',
				       );
    }
}
 


=head2 KButil_Merge_ReadsSet_to_OneLibrary

  $return = $obj->KButil_Merge_ReadsSet_to_OneLibrary($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a kb_util_dylan.KButil_Merge_ReadsSet_to_OneLibrary_Params
$return is a kb_util_dylan.KButil_Merge_ReadsSet_to_OneLibrary_Output
KButil_Merge_ReadsSet_to_OneLibrary_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_ref has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
	desc has a value which is a string
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
KButil_Merge_ReadsSet_to_OneLibrary_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

$params is a kb_util_dylan.KButil_Merge_ReadsSet_to_OneLibrary_Params
$return is a kb_util_dylan.KButil_Merge_ReadsSet_to_OneLibrary_Output
KButil_Merge_ReadsSet_to_OneLibrary_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_ref has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
	desc has a value which is a string
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
KButil_Merge_ReadsSet_to_OneLibrary_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=item Description



=back

=cut

 sub KButil_Merge_ReadsSet_to_OneLibrary
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function KButil_Merge_ReadsSet_to_OneLibrary (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to KButil_Merge_ReadsSet_to_OneLibrary:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'KButil_Merge_ReadsSet_to_OneLibrary');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "kb_util_dylan.KButil_Merge_ReadsSet_to_OneLibrary",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'KButil_Merge_ReadsSet_to_OneLibrary',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method KButil_Merge_ReadsSet_to_OneLibrary",
					    status_line => $self->{client}->status_line,
					    method_name => 'KButil_Merge_ReadsSet_to_OneLibrary',
				       );
    }
}
 


=head2 KButil_Merge_MultipleReadsSets_to_OneReadsSet

  $return = $obj->KButil_Merge_MultipleReadsSets_to_OneReadsSet($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a kb_util_dylan.KButil_Merge_MultipleReadsSets_to_OneReadsSet_Params
$return is a kb_util_dylan.KButil_Merge_MultipleReadsSets_to_OneReadsSet_Output
KButil_Merge_MultipleReadsSets_to_OneReadsSet_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_refs has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
	desc has a value which is a string
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
KButil_Merge_MultipleReadsSets_to_OneReadsSet_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

$params is a kb_util_dylan.KButil_Merge_MultipleReadsSets_to_OneReadsSet_Params
$return is a kb_util_dylan.KButil_Merge_MultipleReadsSets_to_OneReadsSet_Output
KButil_Merge_MultipleReadsSets_to_OneReadsSet_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_refs has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
	desc has a value which is a string
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
KButil_Merge_MultipleReadsSets_to_OneReadsSet_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=item Description



=back

=cut

 sub KButil_Merge_MultipleReadsSets_to_OneReadsSet
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function KButil_Merge_MultipleReadsSets_to_OneReadsSet (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to KButil_Merge_MultipleReadsSets_to_OneReadsSet:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'KButil_Merge_MultipleReadsSets_to_OneReadsSet');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "kb_util_dylan.KButil_Merge_MultipleReadsSets_to_OneReadsSet",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'KButil_Merge_MultipleReadsSets_to_OneReadsSet',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method KButil_Merge_MultipleReadsSets_to_OneReadsSet",
					    status_line => $self->{client}->status_line,
					    method_name => 'KButil_Merge_MultipleReadsSets_to_OneReadsSet',
				       );
    }
}
 


=head2 KButil_Remove_Unpaired_Reads_and_Synchronize_Pairs

  $return = $obj->KButil_Remove_Unpaired_Reads_and_Synchronize_Pairs($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a kb_util_dylan.KButil_Remove_Unpaired_Reads_Params
$return is a kb_util_dylan.KButil_Remove_Unpaired_Reads_Output
KButil_Remove_Unpaired_Reads_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_ref has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
	desc has a value which is a string
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
KButil_Remove_Unpaired_Reads_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

$params is a kb_util_dylan.KButil_Remove_Unpaired_Reads_Params
$return is a kb_util_dylan.KButil_Remove_Unpaired_Reads_Output
KButil_Remove_Unpaired_Reads_Params is a reference to a hash where the following keys are defined:
	workspace_name has a value which is a kb_util_dylan.workspace_name
	input_ref has a value which is a kb_util_dylan.data_obj_ref
	output_name has a value which is a kb_util_dylan.data_obj_name
	desc has a value which is a string
workspace_name is a string
data_obj_ref is a string
data_obj_name is a string
KButil_Remove_Unpaired_Reads_Output is a reference to a hash where the following keys are defined:
	report_name has a value which is a kb_util_dylan.data_obj_name
	report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=item Description



=back

=cut

 sub KButil_Remove_Unpaired_Reads_and_Synchronize_Pairs
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function KButil_Remove_Unpaired_Reads_and_Synchronize_Pairs (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to KButil_Remove_Unpaired_Reads_and_Synchronize_Pairs:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'KButil_Remove_Unpaired_Reads_and_Synchronize_Pairs');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "kb_util_dylan.KButil_Remove_Unpaired_Reads_and_Synchronize_Pairs",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'KButil_Remove_Unpaired_Reads_and_Synchronize_Pairs',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method KButil_Remove_Unpaired_Reads_and_Synchronize_Pairs",
					    status_line => $self->{client}->status_line,
					    method_name => 'KButil_Remove_Unpaired_Reads_and_Synchronize_Pairs',
				       );
    }
}
 
  
sub status
{
    my($self, @args) = @_;
    if ((my $n = @args) != 0) {
        Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
                                   "Invalid argument count for function status (received $n, expecting 0)");
    }
    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
        method => "kb_util_dylan.status",
        params => \@args,
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
                           code => $result->content->{error}->{code},
                           method_name => 'status',
                           data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
                          );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method status",
                        status_line => $self->{client}->status_line,
                        method_name => 'status',
                       );
    }
}
   

sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "kb_util_dylan.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'KButil_Remove_Unpaired_Reads_and_Synchronize_Pairs',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method KButil_Remove_Unpaired_Reads_and_Synchronize_Pairs",
            status_line => $self->{client}->status_line,
            method_name => 'KButil_Remove_Unpaired_Reads_and_Synchronize_Pairs',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for kb_util_dylan::kb_util_dylanClient\n";
    }
    if ($sMajor == 0) {
        warn "kb_util_dylan::kb_util_dylanClient version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 workspace_name

=over 4



=item Description

** The workspace object refs are of form:
**
**    objects = ws.get_objects([{'ref': params['workspace_id']+'/'+params['obj_name']}])
**
** "ref" means the entire name combining the workspace id and the object name
** "id" is a numerical identifier of the workspace or object, and should just be used for workspace
** "name" is a string identifier of a workspace or object.  This is received from Narrative.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 sequence

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 data_obj_name

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 data_obj_ref

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 bool

=over 4



=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 KButil_FASTQ_to_FASTA_Params

=over 4



=item Description

KButil_FASTQ_to_FASTA()
**
** Method for Converting a FASTQ SingleEndLibrary to a FASTA SingleEndLibrary


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_ref has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_ref has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name


=end text

=back



=head2 KButil_FASTQ_to_FASTA_Output

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=back



=head2 KButil_Merge_FeatureSet_Collection_Params

=over 4



=item Description

KButil_Merge_FeatureSet_Collection()
**
**  Method for merging FeatureSets


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_refs has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name
desc has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_refs has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name
desc has a value which is a string


=end text

=back



=head2 KButil_Merge_FeatureSet_Collection_Output

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=back



=head2 KButil_Merge_GenomeSets_Params

=over 4



=item Description

KButil_Merge_GenomeSets()
**
**  Method for merging GenomeSets


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_refs has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name
desc has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_refs has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name
desc has a value which is a string


=end text

=back



=head2 KButil_Merge_GenomeSets_Output

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=back



=head2 KButil_Build_GenomeSet_Params

=over 4



=item Description

KButil_Build_GenomeSet()
**
**  Method for creating a GenomeSet


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_refs has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name
desc has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_refs has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name
desc has a value which is a string


=end text

=back



=head2 KButil_Build_GenomeSet_Output

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=back



=head2 KButil_Build_GenomeSet_from_FeatureSet_Params

=over 4



=item Description

KButil_Build_GenomeSet_from_FeatureSet()
**
**  Method for obtaining a GenomeSet from a FeatureSet


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_ref has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name
desc has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_ref has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name
desc has a value which is a string


=end text

=back



=head2 KButil_Build_GenomeSet_from_FeatureSet_Output

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=back



=head2 KButil_Add_Genomes_to_GenomeSet_Params

=over 4



=item Description

KButil_Add_Genomes_to_GenomeSet()
**
**  Method for adding a Genome to a GenomeSet


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_genome_refs has a value which is a kb_util_dylan.data_obj_ref
input_genomeset_ref has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name
desc has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_genome_refs has a value which is a kb_util_dylan.data_obj_ref
input_genomeset_ref has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name
desc has a value which is a string


=end text

=back



=head2 KButil_Add_Genomes_to_GenomeSet_Output

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=back



=head2 KButil_Concat_MSAs_Params

=over 4



=item Description

KButil_Concat_MSAs()
**
**  Method for Concatenating MSAs into a combined MSA


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_refs has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name
desc has a value which is a string
blanks_flag has a value which is a kb_util_dylan.bool

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_refs has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name
desc has a value which is a string
blanks_flag has a value which is a kb_util_dylan.bool


=end text

=back



=head2 KButil_Concat_MSAs_Output

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=back



=head2 KButil_Split_Reads_Params

=over 4



=item Description

KButil_Split_Reads()
**
**  Method for spliting a ReadsLibrary into evenly sized ReadsLibraries


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_ref has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name
split_num has a value which is an int
desc has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_ref has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name
split_num has a value which is an int
desc has a value which is a string


=end text

=back



=head2 KButil_Split_Reads_Output

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=back



=head2 Fractionate_Options

=over 4



=item Description

KButil_Random_Subsample_Reads()
**
**  Method for random subsampling of reads library


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
split_num has a value which is an int
reads_num has a value which is an int
reads_perc has a value which is a float

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
split_num has a value which is an int
reads_num has a value which is an int
reads_perc has a value which is a float


=end text

=back



=head2 KButil_Random_Subsample_Reads_Params

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_ref has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name
subsample_fraction has a value which is a kb_util_dylan.Fractionate_Options
desc has a value which is a string
seed has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_ref has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name
subsample_fraction has a value which is a kb_util_dylan.Fractionate_Options
desc has a value which is a string
seed has a value which is an int


=end text

=back



=head2 KButil_Random_Subsample_Reads_Output

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=back



=head2 KButil_Merge_ReadsSet_to_OneLibrary_Params

=over 4



=item Description

KButil_Merge_ReadsSet_to_OneLibrary()
**
**  Method for merging a ReadsSet into one library


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_ref has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name
desc has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_ref has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name
desc has a value which is a string


=end text

=back



=head2 KButil_Merge_ReadsSet_to_OneLibrary_Output

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=back



=head2 KButil_Merge_MultipleReadsSets_to_OneReadsSet_Params

=over 4



=item Description

KButil_Merge_MultipleReadsSets_to_OneReadsSet()
**
**  Method for merging multiple ReadsSets into one ReadsSet


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_refs has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name
desc has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_refs has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name
desc has a value which is a string


=end text

=back



=head2 KButil_Merge_MultipleReadsSets_to_OneReadsSet_Output

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=back



=head2 KButil_Remove_Unpaired_Reads_Params

=over 4



=item Description

KButil_Remove_Unpaired_Reads_and_Synchronize_Pairs()
**
**  Method for removing unpaired reads from a paired end library or set and matching the order of reads


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_ref has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name
desc has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace_name has a value which is a kb_util_dylan.workspace_name
input_ref has a value which is a kb_util_dylan.data_obj_ref
output_name has a value which is a kb_util_dylan.data_obj_name
desc has a value which is a string


=end text

=back



=head2 KButil_Remove_Unpaired_Reads_Output

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
report_name has a value which is a kb_util_dylan.data_obj_name
report_ref has a value which is a kb_util_dylan.data_obj_ref


=end text

=back



=cut

package kb_util_dylan::kb_util_dylanClient::RpcClient;
use base 'JSON::RPC::Client';
use POSIX;
use strict;

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $headers, $obj) = @_;
    my $result;


    {
	if ($uri =~ /\?/) {
	    $result = $self->_get($uri);
	}
	else {
	    Carp::croak "not hashref." unless (ref $obj eq 'HASH');
	    $result = $self->_post($uri, $headers, $obj);
	}

    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $headers, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	@$headers,
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
