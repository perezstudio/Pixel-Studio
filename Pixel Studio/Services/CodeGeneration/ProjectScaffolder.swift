import Foundation

/// Creates the SvelteKit project skeleton directory structure and config files.
struct ProjectScaffolder {

    func scaffold(at outputURL: URL, projectName: String) throws {
        let fm = FileManager.default
        let slugName = projectName
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .filter { $0.isLetter || $0.isNumber || $0 == "-" }

        // Create directory structure
        let directories = [
            "src",
            "src/routes",
            "src/lib",
            "src/lib/components",
            "static",
        ]

        for dir in directories {
            let dirURL = outputURL.appendingPathComponent(dir)
            try fm.createDirectory(at: dirURL, withIntermediateDirectories: true)
        }

        // package.json
        let packageJSON = packageJSONTemplate(name: slugName)
        try packageJSON.write(to: outputURL.appendingPathComponent("package.json"), atomically: true, encoding: .utf8)

        // svelte.config.js
        try svelteConfigTemplate().write(to: outputURL.appendingPathComponent("svelte.config.js"), atomically: true, encoding: .utf8)

        // vite.config.ts
        try viteConfigTemplate().write(to: outputURL.appendingPathComponent("vite.config.ts"), atomically: true, encoding: .utf8)

        // src/app.html
        try appHTMLTemplate().write(to: outputURL.appendingPathComponent("src/app.html"), atomically: true, encoding: .utf8)

        // .gitignore
        try gitignoreTemplate().write(to: outputURL.appendingPathComponent(".gitignore"), atomically: true, encoding: .utf8)
    }

    // MARK: - Templates (embedded for reliability)

    private func packageJSONTemplate(name: String) -> String {
        """
        {
          "name": "\(name)",
          "version": "0.0.1",
          "private": true,
          "scripts": {
            "dev": "vite dev",
            "build": "vite build",
            "preview": "vite preview"
          },
          "devDependencies": {
            "@sveltejs/adapter-auto": "^3.0.0",
            "@sveltejs/kit": "^2.0.0",
            "svelte": "^4.0.0",
            "vite": "^5.0.0"
          },
          "type": "module"
        }
        """
    }

    private func svelteConfigTemplate() -> String {
        """
        import adapter from '@sveltejs/adapter-auto';

        /** @type {import('@sveltejs/kit').Config} */
        const config = {
          kit: {
            adapter: adapter()
          }
        };

        export default config;
        """
    }

    private func viteConfigTemplate() -> String {
        """
        import { sveltekit } from '@sveltejs/kit/vite';
        import { defineConfig } from 'vite';

        export default defineConfig({
          plugins: [sveltekit()]
        });
        """
    }

    private func appHTMLTemplate() -> String {
        """
        <!doctype html>
        <html lang="en">
          <head>
            <meta charset="utf-8" />
            <link rel="icon" href="%sveltekit.assets%/favicon.png" />
            <meta name="viewport" content="width=device-width, initial-scale=1" />
            %sveltekit.head%
          </head>
          <body data-sveltekit-prerender="true">
            <div style="display: contents">%sveltekit.body%</div>
          </body>
        </html>
        """
    }

    private func gitignoreTemplate() -> String {
        """
        .DS_Store
        node_modules
        /build
        /.svelte-kit
        /package
        .env
        .env.*
        !.env.example
        vite.config.js.timestamp-*
        vite.config.ts.timestamp-*
        """
    }
}
