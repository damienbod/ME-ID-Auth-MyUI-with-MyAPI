import { Injectable } from '@angular/core';
import { of } from 'rxjs';
import { OidcSecurityService } from 'angular-auth-oidc-client';

@Injectable({ providedIn: 'root' })
export class AuthService {
  constructor(private oidcSecurityService: OidcSecurityService) {}

  accessToken = '';

  get signedIn() {
    return this.oidcSecurityService.isAuthenticated$;
  }

  get token(): string {

    this.oidcSecurityService.getAccessToken().subscribe((token) => {
      this.accessToken = token;
    });

    return this.accessToken;
  }

  get userData() {
    return this.oidcSecurityService.userData$;
  }

  checkAuth() {
    return this.oidcSecurityService.checkAuth();
  }

  signIn() {
    return of(this.oidcSecurityService.authorize());
  }

  signOut() {
    this.oidcSecurityService.logoff();
  }

  forceRefreshSession() {
    return this.oidcSecurityService.forceRefreshSession();
  }
}
