# Represents a Postgres release version. Note that breaking changes
# generally only happen during major or minor version changes. Point
# releases are strictly focused on fixing data integrity or security
# issues.
class PGVersion
  include Comparable

  VERSION = "0.0.4"

  # The major and minor version taken together determine the stable
  # interface to Postgres. New features may be introduced or breaking
  # changes made when either of these change.
  attr_reader :major

  # The major and minor version taken together determine the stable
  # interface to Postgres. New features may be introduced or breaking
  # changes made when either of these change.
  attr_reader :minor

  # The point release, for release states. Always nil when state is
  # not :release.
  attr_reader :point

  # The state of a release: :alpha, :beta, :rc, or :release
  attr_reader :state

  # The revision, for non-release states. A release in a given state
  # may go through several revisions in that state before moving to
  # the next state. Nil when state is :release.
  attr_reader :revision

  # The host architecture of the given binary
  attr_reader :host
  # The compiler used to build the given binary
  attr_reader :compiler
  # Bit depth of the given binary
  attr_reader :bit_depth

  # Parse a Postgres version string, as produced by the function
  # version(), into a PGVersion.
  def self.parse(version_str)
    result = version_str.match VERSION_REGEXP
    raise ArgumentError, "Could not parse version string: #{version_str}" unless result
    point = result[3]
    if point =~ /\A\d+\Z/
      point = point.to_i
    end
    PGVersion.new(result[1].to_i,
                  result[2].to_i,
                  point,
                  host: result[4],
                  compiler: result[5],
                  bit_depth: result[6].to_i)
  end

  # Initialize a new PGVersion
  def initialize(major, minor, point=nil, host: nil, compiler: nil, bit_depth: nil)
    @major = major
    @minor = minor
    if point.is_a?(Integer) || (major >=10 && point.nil?)
      @point = point
      @state = :release
    else
      verstr_states = ALLOWED_STATES.reject { |s| s == :release }.map(&:to_s)
      @state, @revision = point.to_s.match(
                          /(#{verstr_states.join('|')})(\d+)/
                                          ) && $1.to_sym, $2.to_i
      @point = nil
      unless @state && @revision
        raise ArgumentError, "Unknown point release: #{point}"
      end
    end
    @host = host
    @compiler = compiler
    @bit_depth = bit_depth
  end

  # Compare to another PGVersion.
  def <=>(other)
    if self.major < other.major
      -1
    elsif self.major > other.major
      1
    else
      if self.minor < other.minor
        -1
      elsif self.minor > other.minor
        1
      else
        self_state_idx = ALLOWED_STATES.index(self.state)
        other_state_idx = ALLOWED_STATES.index(other.state)
        if self_state_idx < other_state_idx
          -1
        elsif self_state_idx > other_state_idx
          1
        elsif self.state == :release
          self.point <=> other.point
        else
          self.revision <=> other.revision
        end
      end
    end
  end

  def release?; @state == :release; end
  def rc?; @state == :rc; end
  def beta?; @state == :beta; end
  def alpha?; @state == :alpha; end

  # Return the major and minor components of the version as a String,
  # omitting the point release
  def major_minor
    "#{major}.#{minor}"
  end

  def to_s
    patch = if release?
              point.nil? ? "" : ".#{point}"
            else
              "#{state}#{revision}"
            end
    v = "PostgreSQL #{major}.#{minor}#{patch}"
    if host
      v << " on #{host}"
    end
    if compiler
      v << ", compiled by #{compiler}"
    end
    if bit_depth
      v << ", #{bit_depth}-bit"
    end
    v
  end

  protected

  attr_reader :state

  private

  VERSION_REGEXP = /PostgreSQL (\d+)\.(\d+).?((?:alpha|beta|rc)?\d+)? on ([^,]+), compiled by ([^,]+), (\d+)-bit/
  ALLOWED_STATES = %i(alpha beta rc release)
end
