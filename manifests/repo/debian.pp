# Configure debian apt repo
#
# === Parameters
#
# [*location*]
#   Location of the apt repository
#
# [*release*]
#   Release of the apt repository
#
# [*repos*]
#   Apt repository names
#
# [*include_src*]
#   Add source source repository
#
# [*key*]
#   Public key in apt::key format
#
# [*dotdeb*]
#   Enable special dotdeb handling
#
class php::repo::debian(
  $location     = 'https://packages.sury.org/php/',
  $release      = $::lsbdistcodename,
  $repos        = 'main',
  $include_src  = false,
  key        => {
    'id'     => 'DF3D585DB8F0EB658690A554AC0E47584A7A714D',
    'source' => 'https://packages.sury.org/php/apt.gpg',
  },
  $dotdeb = false,
) {

  if $caller_module_name != $module_name {
    warning('php::repo::debian is private')
  }

  include '::apt'

  create_resources(::apt::key, { 'php::repo::debian' => {
    id     => $key['id'],
    source => $key['source'],
  }})

  ::apt::source { "source_php_${release}":
    location => $location,
    release  => $release,
    repos    => $repos,
    include  => {
      'src' => $include_src,
      'deb' => true,
    },
    require  => Apt::Key['php::repo::debian'],
  }

  if ($dotdeb) {
    # both repositories are required to work correctly
    # See: http://www.dotdeb.org/instructions/
    if $release == 'wheezy-php56' {
      ::apt::source { 'dotdeb-wheezy':
        location => $location,
        release  => 'wheezy',
        repos    => $repos,
        include  => {
          'src' => $include_src,
          'deb' => true,
        },
      }
    }
  }
}
