# Locale
export LANG="en_US.UTF-8"
export LANGUAGE="en_US:en"
export LC_CTYPE="UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_PAPER="en_US.UTF-8"
export LC_NAME="en_US.UTF-8"
export LC_ADDRESS="en_US.UTF-8"
export LC_TELEPHONE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_MEASUREMENT="en_US.UTF-8"
export LC_IDENTIFICATION="en_US.TF-8"

# Change working directory to the top-most Finder window location
function cdf() {
	cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')";
}
