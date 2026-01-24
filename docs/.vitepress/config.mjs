import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'MLOps Training',
  description: 'Hands-on training for MLOps infrastructure, deployment, and CI/CD',

  // Clean URLs (no .html extension)
  cleanUrls: true,

  // Ignore dead links for work-in-progress documentation
  ignoreDeadLinks: true,

  themeConfig: {
    // Site navigation
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Study Guide', link: '/README' },
      { text: 'Module 1', link: '/module-01/README' },
      { text: 'Module 3', link: '/module-03/README' },
    ],

    // Sidebar configuration
    sidebar: {
      '/': [
        {
          text: 'Getting Started',
          items: [
            { text: 'Study Guide', link: '/README' },
          ]
        },
        {
          text: 'Module 1: Infrastructure & Prerequisites',
          collapsed: false,
          items: [
            { text: 'Module Overview', link: '/module-01/README' },
            {
              text: 'Git for Teams',
              collapsed: true,
              items: [
                { text: 'Overview', link: '/module-01/git/README' },
                { text: 'Git Basics', link: '/module-01/git/git-basics' },
                { text: 'Understanding Git Areas', link: '/module-01/git/git-areas' },
                { text: 'Repository Governance', link: '/module-01/git/repository-governance' },
                {
                  text: 'Branching Strategies',
                  collapsed: true,
                  items: [
                    { text: 'Strategy Overview', link: '/module-01/git/branching-strategies' },
                    { text: 'Trunk-Based Development', link: '/module-01/git/trunk-based' },
                    { text: 'Git Flow', link: '/module-01/git/git-flow' },
                    { text: 'GitHub Flow', link: '/module-01/git/github-flow' }
                  ]
                },
                { text: 'Remote Operations', link: '/module-01/git/remote-operations' },
                { text: 'Pull Requests & Code Review', link: '/module-01/git/pull-requests' },
                { text: 'Merge Conflicts', link: '/module-01/git/merge-conflicts' },
                { text: 'Team Conventions', link: '/module-01/git/team-conventions' },
                { text: 'Workflow Examples', link: '/module-01/git/workflow-examples' }
              ]
            },
            {
              text: 'AWS Cloud Services',
              collapsed: true,
              items: [
                { text: 'AWS Overview', link: '/module-01/aws/README' },
                { text: 'Cloud Concepts (Domain 1)', link: '/module-01/aws/cloud-concepts' },
                { text: 'Security & Compliance (Domain 2)', link: '/module-01/aws/security-compliance' },
                { text: 'Deployment Methods', link: '/module-01/aws/deployment-methods' },
                { text: 'Compute Services', link: '/module-01/aws/compute-services' },
                { text: 'Storage Services', link: '/module-01/aws/storage-services' },
                { text: 'Database Services', link: '/module-01/aws/database-services' },
                { text: 'Networking Services', link: '/module-01/aws/networking-services' },
                { text: 'Analytics Services', link: '/module-01/aws/analytics-services' },
                { text: 'AI/ML Services', link: '/module-01/aws/ai-ml-services' },
                { text: 'Billing & Pricing (Domain 4)', link: '/module-01/aws/billing-pricing' },
                {
                  text: 'LocalStack Labs',
                  collapsed: true,
                  items: [
                    { text: 'Quick Start', link: '/module-01/aws/localstack/quick-start' },
                    { text: 'Full Guide', link: '/module-01/aws/localstack/guide' },
                    { text: 'Compute Practice', link: '/module-01/aws/localstack/compute' },
                    { text: 'Storage & Database Practice', link: '/module-01/aws/localstack/storage-database' },
                    { text: 'Networking & Analytics Practice', link: '/module-01/aws/localstack/networking-analytics-security' }
                  ]
                }
              ]
            },
            {
              text: 'Kubernetes',
              collapsed: true,
              items: [
                { text: 'Overview', link: '/module-01/k8s/README' },
                { text: 'Why Kubernetes?', link: '/module-01/k8s/01-overview/README' },
                {
                  text: 'Key Concepts - Core Objects',
                  collapsed: true,
                  items: [
                    { text: 'Overview', link: '/module-01/k8s/02-key-concepts/core-objects/README' },
                    { text: 'Object Model', link: '/module-01/k8s/02-key-concepts/core-objects/object-model' },
                    { text: 'Namespaces', link: '/module-01/k8s/02-key-concepts/core-objects/namespaces' },
                    { text: 'Pods', link: '/module-01/k8s/02-key-concepts/core-objects/pods' },
                    { text: 'Labels & Selectors', link: '/module-01/k8s/02-key-concepts/core-objects/labels-selectors' }
                  ]
                },
                {
                  text: 'Key Concepts - Workloads',
                  collapsed: true,
                  items: [
                    { text: 'Overview', link: '/module-01/k8s/02-key-concepts/workloads/README' },
                    { text: 'ReplicaSet', link: '/module-01/k8s/02-key-concepts/workloads/replicaset' },
                    { text: 'Deployment', link: '/module-01/k8s/02-key-concepts/workloads/deployment' },
                    { text: 'DaemonSet', link: '/module-01/k8s/02-key-concepts/workloads/daemonset' },
                    { text: 'StatefulSet', link: '/module-01/k8s/02-key-concepts/workloads/statefulset' },
                    { text: 'Job', link: '/module-01/k8s/02-key-concepts/workloads/job' },
                    { text: 'CronJob', link: '/module-01/k8s/02-key-concepts/workloads/cronjob' }
                  ]
                },
                {
                  text: 'Key Concepts - Storage',
                  collapsed: true,
                  items: [
                    { text: 'Overview', link: '/module-01/k8s/02-key-concepts/storage/README' }
                  ]
                },
                {
                  text: 'Key Concepts - Configuration',
                  collapsed: true,
                  items: [
                    { text: 'Overview', link: '/module-01/k8s/02-key-concepts/configuration/README' }
                  ]
                },
                {
                  text: 'Key Concepts - Network',
                  collapsed: true,
                  items: [
                    { text: 'Overview', link: '/module-01/k8s/02-key-concepts/network/README' }
                  ]
                },
                {
                  text: 'Architecture',
                  collapsed: true,
                  items: [
                    { text: 'Overview', link: '/module-01/k8s/03-architecture/README' },
                    { text: 'Control Plane', link: '/module-01/k8s/03-architecture/control-plane' },
                    { text: 'Node Components', link: '/module-01/k8s/03-architecture/node-components' },
                    { text: 'Optional Services', link: '/module-01/k8s/03-architecture/optional-services' },
                    { text: 'Networking Model', link: '/module-01/k8s/03-architecture/networking-model' }
                  ]
                },
                { text: 'Helm Package Manager', link: '/module-01/k8s/04-helm/README' },
                { text: 'Monitoring & Observability', link: '/module-01/k8s/05-monitoring/README' }
              ]
            }
          ]
        },
        {
          text: 'Module 3: Deployment and Operation',
          collapsed: false,
          items: [
            { text: 'Module Overview', link: '/module-03/README' },
            {
              text: 'Testing',
              collapsed: true,
              items: [
                { text: 'Overview', link: '/module-03/testing/unit/README' },
              ]
            },
            {
              text: 'CI/CD',
              collapsed: true,
              items: [
                { text: 'Overview', link: '/module-03/cicd/github-actions/README' },
              ]
            },
            {
              text: 'Monitoring & Observability',
              collapsed: true,
              items: [
                { text: 'Quick Start with intro-to-mltp', link: '/module-03/monitoring/README' },
                {
                  text: 'Grafana',
                  collapsed: true,
                  items: [
                    { text: 'Overview & Architecture', link: '/module-03/monitoring/grafana' },
                  ]
                },
                {
                  text: 'Grafana Mimir (Metrics)',
                  collapsed: true,
                  items: [
                    { text: 'Overview & Architecture', link: '/module-03/monitoring/mimir' },
                  ]
                },
                {
                  text: 'Grafana Loki (Logs)',
                  collapsed: true,
                  items: [
                    { text: 'Overview & Architecture', link: '/module-03/monitoring/loki' },
                  ]
                },
                {
                  text: 'Grafana Tempo (Traces)',
                  collapsed: true,
                  items: [
                    { text: 'Overview & Architecture', link: '/module-03/monitoring/tempo' },
                  ]
                },
                {
                  text: 'Grafana Pyroscope (Profiles)',
                  collapsed: true,
                  items: [
                    { text: 'Overview & Architecture', link: '/module-03/monitoring/pyroscope' },
                  ]
                },
                { text: 'Quickstart Guide', link: '/module-03/monitoring/quickstart' },
              ]
            }
          ]
        }
      ]
    },

    // Social links
    socialLinks: [
      { icon: 'github', link: 'https://github.com/ptnglobalcorp/mlops_traning' }
    ],

    // Footer
    footer: {
      message: 'Released under the MIT License.',
      copyright: 'Copyright © 2026-present'
    },

    // Edit link
    editLink: {
      pattern: 'https://github.com/ptnglobalcorp/mlops_traning/edit/main/docs/:path',
      text: 'Edit this page on GitHub'
    },

    // Last updated text
    lastUpdated: {
      text: 'Last updated',
      formatOptions: {
        dateStyle: 'full',
        timeStyle: 'medium'
      }
    },

    // Search
    search: {
      provider: 'local'
    }
  },

  // Markdown configurations
  markdown: {
    // Line numbers in code blocks
    lineNumbers: true,

    // Language display
    config: (md) => {
      // Add custom markdown-it plugins if needed
      return md
    }
  },

  // Build optimizations
  vite: {
    build: {
      chunkSizeWarningLimit: 1000
    }
  }
})
