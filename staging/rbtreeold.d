import std.stdio;

import hurt.conv.conv;

enum Color { RED, BLACK }

class Node(T) {
    public T key;
    public Node!(T) left;
    public Node!(T) right;
    public Node!(T) parent;
    public Color color;

    public this(T key, Color nodeColor, Node!(T) left, Node!(T) right) {
        this.key = key;
        this.color = nodeColor;
        this.left = left;
        this.right = right;
        if(left  !is null)
			left.parent = this;
        if(right !is null) 
			right.parent = this;
        this.parent = null;
    }

    public Node!(T) grandparent() {
		if(this.parent !is null && this.parent.parent !is null) {
        	return this.parent.parent;
		} else {
			return null;
		}
    }

    public Node!(T) sibling() {
        if(this.parent is null)
			return null; // Root node has no sibling
        if(this is this.parent.left)
            return this.parent.right;
        else
            return this.parent.left;
    }

    public Node!(T) uncle() {
		if(this.parent !is null && this.parent.parent !is null) {
        	//assert(this.parent !is null); // Root node has no uncle
        	//assert(this.parent.parent !is null); // Children of root have no uncle
        	return this.parent.sibling();
		} else {
			return null;
		}
    }

}

public class RBTree(T) {
    public Node!(T) root;

    public this() {
        this.root = null;
        this.verifyProperties();
    }

	public bool validate() {
		this.verifyProperties();
		return true;
	}

    public void verifyProperties() {
    	verifyProperty1(root);
    	verifyProperty2(root);
    	// Property 3 is implicit
    	verifyProperty4(root);
    	verifyProperty5(root);
    }

    private static void verifyProperty1(Node!(T) n) {
        assert(nodeColor(n) == Color.RED || nodeColor(n) == Color.BLACK);
        if(n is null) 
			return;
        verifyProperty1(n.left);
        verifyProperty1(n.right);
    }

    private static void verifyProperty2(Node!(T) root) {
        assert(nodeColor(root) == Color.BLACK);
    }

    private static Color nodeColor(Node!(T) n) {
        return(n is null ? Color.BLACK : n.color);
    }

    private static void verifyProperty4(Node!(T) n) {
        if(nodeColor(n) == Color.RED) {
            assert(nodeColor(n.left) == Color.BLACK);
            assert(nodeColor(n.right) == Color.BLACK);
            assert(nodeColor(n.parent) == Color.BLACK);
        }
        if(n is null) 
			return;
        verifyProperty4(n.left);
        verifyProperty4(n.right);
    }

    private static void verifyProperty5(Node!(T) root) {
        verifyProperty5Helper(root, 0, -1);
    }

    private static int verifyProperty5Helper(Node!(T) n, int blackCount, int pathBlackCount) {
        if(nodeColor(n) == Color.BLACK) {
            blackCount++;
        }
        if(n is null) {
            if(pathBlackCount == -1) {
                pathBlackCount = blackCount;
            } else {
                assert(blackCount == pathBlackCount);
            }
            return pathBlackCount;
        }
        pathBlackCount = verifyProperty5Helper(n.left, blackCount, pathBlackCount);
        pathBlackCount = verifyProperty5Helper(n.right, blackCount, pathBlackCount);
        return pathBlackCount;
    }

	private Node!(T) search(T key) {
		return this.lookupNode(key);
	}

    private Node!(T) lookupNode(T key) {
        Node!(T) n = root;
        while(n !is null) {
            //int compResult = key.compareTo(n.key);
            int compResult = key < n.key;
            if(compResult == 0) {
                return n;
            } else if(compResult < 0) {
                n = n.left;
            } else {
                assert(compResult > 0);
                n = n.right;
            }
        }
        return n;
    }

    /*public T lookup(T key) {
        Node!(T) n = this.lookupNode(key);
        return n is null ? null : n.key;
    }*/

    private void rotateLeft(Node!(T) n) {
        Node!(T) r = n.right;
        replaceNode(n, r);
        n.right = r.left;
        if(r.left !is null) {
            r.left.parent = n;
        }
        r.left = n;
        n.parent = r;
    }

    private void rotateRight(Node!(T) n) {
        Node!(T) l = n.left;
        replaceNode(n, l);
        n.left = l.right;
        if(l.right !is null) {
            l.right.parent = n;
        }
        l.right = n;
        n.parent = l;
    }

    private void replaceNode(Node!(T) oldn, Node!(T) newn) {
        if(oldn.parent is null) {
            root = newn;
        } else {
            if(oldn is oldn.parent.left)
                oldn.parent.left = newn;
            else
                oldn.parent.right = newn;
        }
        if(newn !is null) {
            newn.parent = oldn.parent;
        }
    }

    public void insert(T key) {
        Node!(T) insertedNode = new Node!(T)(key, Color.RED, null, null);
        if(this.root is null) {
            this.root = insertedNode;
        } else {
            Node!(T) n = this.root;
            while(true) {
                //int compResult = key.compareTo(n.key);
                int compResult = key < n.key;
                if(compResult == 0) {
                    n.key = key;
                    return;
                } else if(compResult < 0) {
                    if(n.left is null) {
                        n.left = insertedNode;
                        break;
                    } else {
                        n = n.left;
                    }
                } else {
                    assert(compResult > 0);
                    if(n.right is null) {
                        n.right = insertedNode;
                        break;
                    } else {
                        n = n.right;
                    }
                }
            }
            insertedNode.parent = n;
        }
        insertCase1(insertedNode);
        verifyProperties();
    }

    private void insertCase1(Node!(T) n) {
        if(n.parent is null)
            n.color = Color.BLACK;
        else
            insertCase2(n);
    }

    private void insertCase2(Node!(T) n) {
        if(nodeColor(n.parent) == Color.BLACK)
            return; // Tree is still valid
        else
            insertCase3(n);
    }

    void insertCase3(Node!(T) n) {
        if(nodeColor(n.uncle()) == Color.RED) {
            n.parent.color = Color.BLACK;
            n.uncle().color = Color.BLACK;
            n.grandparent().color = Color.RED;
            insertCase1(n.grandparent());
        } else {
            insertCase4(n);
        }
    }

    void insertCase4(Node!(T) n) {
        if(n == n.parent.right && n.parent == n.grandparent().left) {
            rotateLeft(n.parent);
            n = n.left;
        } else if(n == n.parent.left && n.parent == n.grandparent().right) {
            rotateRight(n.parent);
            n = n.right;
        }
        insertCase5(n);
    }

    void insertCase5(Node!(T) n) {
        n.parent.color = Color.BLACK;
        n.grandparent().color = Color.RED;
        if(n == n.parent.left && n.parent == n.grandparent().left) {
            rotateRight(n.grandparent());
        } else {
            assert(n is n.parent.right && n.parent is n.grandparent().right);
            rotateLeft(n.grandparent());
        }
    }

    public void remove(T key) {
        Node!(T) n = lookupNode(key);
        if (n is null)
            return;  // Key not found, do nothing
        if(n.left !is null && n.right !is null) {
            // Copy key/value from predecessor and then delete it instead
            Node!(T) pred = maximumNode(n.left);
            n.key = pred.key;
            n = pred;
        }

        assert(n.left is null || n.right is null);
        Node!(T) child = (n.right is null) ? n.left : n.right;
        if(nodeColor(n) == Color.BLACK) {
            n.color = nodeColor(child);
            deleteCase1(n);
        }
        replaceNode(n, child);
        
        if(nodeColor(root) == Color.RED) {
            root.color = Color.BLACK;
        }

        verifyProperties();
    }

    private static Node!(T) maximumNode(Node!(T) n) {
        assert(n !is null);
        while(n.right !is null) {
            n = n.right;
        }
        return n;
    }

    private void deleteCase1(Node!(T) n) {
        if(n.parent is null)
            return;
        else
            deleteCase2(n);
    }

    private void deleteCase2(Node!(T) n) {
        if(nodeColor(n.sibling()) == Color.RED) {
            n.parent.color = Color.RED;
            n.sibling().color = Color.BLACK;
            if(n is n.parent.left)
                rotateLeft(n.parent);
            else
                rotateRight(n.parent);
        }
        deleteCase3(n);
    }

    private void deleteCase3(Node!(T) n) {
        if(nodeColor(n.parent) == Color.BLACK &&
            nodeColor(n.sibling()) == Color.BLACK &&
            nodeColor(n.sibling().left) == Color.BLACK &&
            nodeColor(n.sibling().right) == Color.BLACK)
        {
            n.sibling().color = Color.RED;
            deleteCase1(n.parent);
        } else
            deleteCase4(n);
    }

    private void deleteCase4(Node!(T) n) {
        if(nodeColor(n.parent) == Color.RED &&
            nodeColor(n.sibling()) == Color.BLACK &&
            nodeColor(n.sibling().left) == Color.BLACK &&
            nodeColor(n.sibling().right) == Color.BLACK)
        {
            n.sibling().color = Color.RED;
            n.parent.color = Color.BLACK;
        } else
            deleteCase5(n);
    }

    private void deleteCase5(Node!(T) n) {
        if(n is n.parent.left &&
            nodeColor(n.sibling()) == Color.BLACK &&
            nodeColor(n.sibling().left) == Color.RED &&
            nodeColor(n.sibling().right) == Color.BLACK)
        {
            n.sibling().color = Color.RED;
            n.sibling().left.color = Color.BLACK;
            rotateRight(n.sibling());
        } else if(n is n.parent.right &&
                 nodeColor(n.sibling()) == Color.BLACK &&
                 nodeColor(n.sibling().right) == Color.RED &&
                 nodeColor(n.sibling().left) == Color.BLACK)
        {
            n.sibling().color = Color.RED;
            n.sibling().right.color = Color.BLACK;
            rotateLeft(n.sibling());
        }
        deleteCase6(n);
    }

    private void deleteCase6(Node!(T) n) {
        n.sibling().color = nodeColor(n.parent);
        n.parent.color = Color.BLACK;
        if(n is n.parent.left) {
            assert(nodeColor(n.sibling().right) == Color.RED);
            n.sibling().right.color = Color.BLACK;
            rotateLeft(n.parent);
        } else {
            assert(nodeColor(n.sibling().left) == Color.RED);
            n.sibling().left.color = Color.BLACK;
            rotateRight(n.parent);
        }
    }

    public void print() {
        printHelper(root, 0);
    }

    private static void printHelper(Node!(T) n, int indent) {
        if(n is null) {
            write("<empty tree>");
            return;
        }
        if(n.right !is null) {
            printHelper(n.right, indent + 2);
        }
        for(int i = 0; i < indent; i++)
            write(" ");
        if(n.color == Color.BLACK)
            writeln(n.key);
        else
            writeln("<", n.key, ">");
        if (n.left !is null) {
            printHelper(n.left, indent + 2);
        }
    }
}

bool compare(T)(RBTree!(T) t, T[T] s) {
	/*if(t.getSize() != s.length) {
		writeln(__LINE__, " size wrong");
		return false;
	}*/
	foreach(it; s.values) {
		if(t.search(it) is null) {
			writeln(__LINE__, " value not presents " ~ conv!(T,string)(it));
			return false;
		}
	}
	return true;
}

void main() {
	int[][] lot = [[2811, 1089, 3909, 3593, 1980, 2863, 676, 258, 2499, 3147,
	3321, 3532, 3009, 1526, 2474, 1609, 518, 1451, 796, 2147, 56, 414, 3740,
	2476, 3297, 487, 1397, 973, 2287, 2516, 543, 3784, 916, 2642, 312, 1130,
	756, 210, 170, 3510, 987], [0,1,2,3,4,5,6,7,8,9,10],
	[10,9,8,7,6,5,4,3,2,1,0],[10,9,8,7,6,5,4,3,2,1,0,11],
	[0,1,2,3,4,5,6,7,8,9,10,-1],[11,1,2,3,4,5,6,7,8,0]];
	foreach(lots; lot) {
		RBTree!(int) a = new RBTree!(int)();
		int[int] at;
		foreach(idx, it; lots) {
			a.insert(it);
			writeln("\n",__LINE__," ", it);
			a.print();
			at[it] = it;
			assert(compare!(int)(a,at));
			assert(a.validate());
			//assert(a.getSize() == idx+1);
			foreach(jt; lots[0..idx+1]) {
				assert(a.search(jt) !is null);
			}
		}
		foreach(idx, it; lots) {
			a.remove(it);
			at.remove(it);
			assert(compare!(int)(a,at));
			//assert(a.getSize() == lots.length-idx-1);
			assert(a.validate());
			foreach(jt; lots[0..idx]) {
				assert(a.search(jt) is null);
			}
			foreach(jt; lots[idx+1..$]) {
				assert(a.search(jt) !is null);
			}
		}
	}
	writeln("bst test done");
}
