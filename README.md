PD (Persistent Datastructure)
======================
Eonil, 2019.

A collection of protocols and default implementation of some persistent datastructures.

Persistence
--------------

Transmission
----------------
Changes in a repository are stored in `timeline`.
These changes can be transmitted to another repository
by replaying changes in the target repository.
It's simple to transfer changes to another repository.
See `PDTreeTransmission` type for details.

It's also possible to transfer changes to your own datastructure.
It needs writing manual iteration of changes, but still quite doable.
Here's an example of how to implement transmission into another datastructure.
`OT4Source` is a tree datastructure but in little bit different shape.
See how I make `news` timeline and iterate over from/to elements in each
steppings.

    private var transferredVersion = AnyHashable(Identity())
    private var viewSource = OT4Source<Identity,EPIssueContent>()

    private func process(_ c: Control) {
        switch c {
        case .render(let repo):
            let news = (repo.latest(since: transferredVersion) ?? repo).timeline
            for step in news {
                for (idxp,_) in step.from.reversed() {
                    let id = viewSource.timeline.last!.identity(at: idxp)
                    viewSource.timeline.remove(for: id)
                }
                for (idxp,tree) in step.to {
                    viewSource.timeline.insert(tree.content, for: tree.identity, at: idxp)
                }
            }
            transferredVersion = news.versions.last ?? transferredVersion
        }
    }



Credits & License
---------------------
The code has been copied form [Github](https://github.com/attaswift/BTree).
The code has been embedded for convenience and performance.

All other code is written by Eonil, Hoon H. and licensed under MIT License.

