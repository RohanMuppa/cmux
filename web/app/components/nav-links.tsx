"use client";

import Link from "next/link";

export function NavLinks() {
  return (
    <>
      <Link
        href="/docs/getting-started"
        className="hover:text-foreground transition-colors"
      >
        Docs
      </Link>
      <Link
        href="/blog"
        className="hover:text-foreground transition-colors"
      >
        Blog
      </Link>
      <Link
        href="/docs/changelog"
        className="hover:text-foreground transition-colors"
      >
        Changelog
      </Link>
      <Link
        href="/community"
        className="hover:text-foreground transition-colors"
      >
        Community
      </Link>
      <a
        href="https://github.com/manaflow-ai/cmux"
        target="_blank"
        rel="noopener noreferrer"
        className="hover:text-foreground transition-colors"
      >
        GitHub
      </a>
    </>
  );
}
