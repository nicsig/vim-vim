vim9script noclear

if exists('loaded') | finish | endif
var loaded = true

def vim#syntax#tweakCluster(acluster: string, group: string, action = 'include')
    var cluster: string = acluster->substitute('^@', '', '')
    cluster = execute('syn list @' .. cluster)
        ->split('\n')
        ->filter((_, v: string): bool => v =~ '^' .. cluster)[0]
    var cmd: string = 'syn cluster '
        .. cluster
            ->substitute('cluster=', 'contains=', '')
            ->substitute('\s*$', '', '')
    if action == 'include'
        cmd ..= ',' .. group
    elseif action == 'exclude'
        cmd = cmd
            ->substitute(
                # pattern matching the group to remove be it:{{{
                #
                #  - in the middle of the cluster
                #  - at the start of the cluster
                #  - in the end of the cluster
                #
                #}}}
                printf(',%s\|=\zs%s,\|,%s$', group, group, group),
                '', 'g')
    endif
    exe cmd
enddef
