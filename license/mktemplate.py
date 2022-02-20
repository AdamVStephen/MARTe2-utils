#!/usr/bin/env python
#
import pdb
import sys


class CommentTemplate:
	def __init__(self, commentchar = "//", title="SECTION", source='copyright-clause.txt'):
		self.title = title
		self.commentchar = commentchar
		with open(source, 'r') as fh:
			self.lines = fh.readlines()
	def set_commentchar(self, commentchar):
		self.commentchar = commentchar
	def __repr__(self):
		r = []
		r.append('%s %s' % (self.title, self.commentchar))
		r.append('%s' % self.commentchar)
		for l in self.clause_lines:
			r.append('%s %s' % (self.commentchar, l)
		r.append('%s' % self.commentchar)
		return '\n'.join(r)

class CopyrightTemplate(CommentTemplate):
	def __init__(self, commentchar = "//", title="COPYRIGHT", source="copyright-clause.txt"):
		CommentTemplate.__init__(self, commentchar = commentchar, title=title, source=source)

class LicenseTemplate(CommentTemplate):
	def __init__(self, commentchar = "//", title="LICENSE", source="license-clause.txt"):
		CommentTemplate.__init__(self, commentchar = commentchar, title=title, source=source)

def generate(commentchar = "//")
	r = []
	pdb.set_trace()
	ctemp = CopyrightTemplate(commentchar)
	r.append('%s' % ctemp)
	ltemp = LicenseTemplate(commentchar)
	r.append('%s' % ltemp)
	return '\n'.join(r)

if __name___ == '__main__':
	commentchar = sys.argv[1]
	print(generate(commentchar))
