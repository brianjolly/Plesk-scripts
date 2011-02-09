#!/bin/bash

username=$1
subdomain=$2
subdomain_path="/var/www/vhosts/cl-sf.com/subdomains/$subdomain"

echo ""

create_sub_domain() 
{
    echo "Creating subdomain $subdomain.cl-sf.com"
    cd /usr/local/psa/bin/
    ./subdomain --create $subdomain -domain cl-sf.com
    rm -rf $subdomain_path/httpdocs/*
    echo "<html> <p>$subdomain server</p> </html>" >> "$subdomain_path/httpdocs/index.html"
    echo ""
}

set_up_user()
{
    echo "Setting up user: $username"
    /usr/sbin/useradd $username
    #/usr/sbin/usermod -d /home/$username $username
    /usr/sbin/usermod -d $subdomain_path $username
    /usr/sbin/usermod -a -G developers $username
    passwd $username
    echo ""
}

set_up_git_repo()
{
    echo "Set up Git Repository"
    cd $subdomain_path

    echo " - creating .gitignore in /home/$username"
    echo ".DS_Store" > .gitignore
    echo "*.swp" >> .gitignore
    echo "*.swo" >> .gitignore
    echo ".bash_logout" >> .gitignore
    echo ".bash_profile" >> .gitignore
    echo ".bashrc" >> .gitignore
    echo ".emacs" >> .gitignore
    echo ".lesshst" >> .gitignore
    echo ".viminfo" >> .gitignore
    echo ".gitconfig" >> .gitignore

    echo " - setting users git settings"
    git config --global user.email "$username@creativelift.net"
    git config --global user.name $username
    git init
    git add .gitignore
    git add httpdocs
    git commit -m "Initial Commit"
    echo ""

    echo "Clone Git repo with:"
    echo "git clone $username@cl-sf.com:~ $subdomain"
    echo ""
    echo "Project URL IS: $subdomain.cl-sf.com"
    echo ""
}

enable_git_post_rec_hook()
{

    echo "#!/bin/sh" > "$subdomain_path/.git/hooks/post-receive"
    echo "cd .." >> "$subdomain_path/.git/hooks/post-receive"
    echo "env -i git reset --hard ">> "$subdomain_path/.git/hooks/post-receive"
    chmod u+x "$subdomain_path/.git/hooks/post-receive"

    # twitter
    #latestLog=`env -i git log -1 --pretty=format:"%an %h %s"`
    #truncatedLog=`expr substr "$latestLog" 1 140`
    #curl --silent --basic --user "bundlebuilder4:8california" --data-ascii \
    #"status=$truncatedLog" http://twitter.com/statuses/update.json >/dev/null 2>&1
}

set_permissions()
{
    chown -R $username:developers $subdomain_path 
    #chown -R clsf:developers "$subdomain_path/httpdocs"
    chmod 755 "$subdomain_path"
    chmod 775 "$subdomain_path/httpdocs"
}

create_sub_domain && set_up_user && set_up_git_repo && enable_git_post_rec_hook && set_permissions

exit 0
