
include_recipe "users::default"

users = search :users, node[:users][:groups].map{ |g| "groups:#{g}" }.join(" OR ")

users.each do |u|
  if u['dotfiles']
    home_dir = "/home/#{u['id']}"
    dotfiles = u['dotfiles']
    dotfiles_url = u['dotfiles']['url']

    git "dotfiles" do
      repository  dotfiles_url
      destination "#{home_dir}/dotfiles"
      reference "master"
      action :checkout
      user u['id']
      group u['id']
    end

    script "update and install dotfiles" do
      interpreter "bash"
      code <<-EOF
       # These files are actively developed, so we can't have chef doing git reset --hard
       # whenever it pleases. Willy nilly merges aren't much better as they could potentially 
       # mess up working copies, make vim panic, you could lose changes, all sorts of evil.
       #
       # The best solution I can come up with is to just leave the directory alone if the 
       # index or working copy are dirty. Of course this means that you'll have to commit 
       # your changes on a machine before you log out, but that's not too much to ask, is it?
       
       cd #{home_dir}/dotfiles 

       # Chef uses "deploy" branch for SCM resources which is annoying.
       # Incidentally, we also have the awkwardness of HEAD being on the wrong branch...
       git checkout master
       git branch -d deploy

       # Tags are harmless, right?
       git fetch origin
       git fetch origin --tags
       

       if git diff-index --exit-code --quiet HEAD
       then
        # TODO: What if the dotfiles aren't on master?
        #[ git name-rev --name-only HEAD == "master" ] || git checkout master
        git merge origin/master
        
        if [ $? -ne 0 ]
        then
          # Bad merge. Forget it. Let the developer sort it out next time they take a look.
          git reset --hard
        fi

        # If there's a setup or install file run it (prefer setup if both exist).
        ([ -x ./setup.sh ] && ./setup.sh) || ([ -x ./install.sh ] && ./install.sh )
      fi
      
      # chown -R #{u['id']}:#{u['id']} .

      # Chef doesn't like non-zero exit status. Hopefully we've done enough checking above.
      # If you haven't got a setup file or it fails then that's your own problem.
      exit 0
EOF
    end

  end
end
