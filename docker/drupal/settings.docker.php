<?php

/**
 * @file
 * Docker settings. Included from settings.php; every value comes from .env.
 */

$databases['default']['default'] = [
  'driver' => 'mysql',
  'host' => getenv('DB_HOST') ?: 'db',
  'port' => getenv('DB_PORT') ?: '3306',
  'database' => getenv('DB_NAME'),
  'username' => getenv('DB_USER'),
  'password' => getenv('DB_PASSWORD'),
  'prefix' => '',
  'collation' => 'utf8mb4_general_ci',
  'namespace' => 'Drupal\\mysql\\Driver\\Database\\mysql',
  'autoload' => 'core/modules/mysql/src/Driver/Database/mysql/',
  'init_commands' => [
    'isolation_level' => 'SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED',
  ],
];

$settings['hash_salt'] = getenv('DRUPAL_HASH_SALT');
$settings['config_sync_directory'] = '../config/sync';
$settings['file_private_path'] = '../private';

// Only answer to the host names listed in DRUPAL_TRUSTED_HOSTS.
$settings['trusted_host_patterns'] = [];
foreach (array_filter(array_map('trim', explode(',', getenv('DRUPAL_TRUSTED_HOSTS') ?: 'localhost'))) as $host) {
  $settings['trusted_host_patterns'][] = '^' . preg_quote($host) . '$';
}

// Cloudflare Tunnel terminates HTTPS; tell Drupal the visitor is on https.
if (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https') {
  $_SERVER['HTTPS'] = 'on';
}
