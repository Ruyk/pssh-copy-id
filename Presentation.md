
---

# SYNOPSIS #

```

        pssh-copy-id [-i pub_file] [-l|u username] host1 host2 ... hostN 
        pssh-copy-id [-i pub_file] [-l|u username] name1@host1 name2@host2 ... nameN@hostN 

```



---

# OPTIONS #

Options

  * `-i pub_file`
File where the public key reside, default $HOME/.ssh/id\_rsa.pub

  * `-l username`
Same as -u, compatibility with ssh options.

  * `-u username`
Remote username (must be the same for all the machines)

  * `-v` verbose



---

# AUTHOR #

Ruyman Reyes Castro, rreyes@ull.es

Thanks to Casiano Rodriguez-Leon for the idea