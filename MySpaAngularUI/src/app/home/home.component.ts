import { Component, OnInit } from '@angular/core';
import { Observable, of } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { AuthService } from '../auth.service';
import { HttpClient } from '@angular/common/http';
import { ConfigAuthenticatedResult } from 'angular-auth-oidc-client';

@Component({
  selector: 'app-home',
  templateUrl: 'home.component.html',
})
export class HomeComponent implements OnInit {
  userData$: Observable<any>;
  dataFromAzureProtectedApi$: Observable<any>;
  isAuthenticated$: Observable<boolean | ConfigAuthenticatedResult[]>;
  constructor(
    private authservice: AuthService,
    private httpClient: HttpClient
  ) {}

  ngOnInit() {
    this.userData$ = this.authservice.userData;
    this.isAuthenticated$ = this.authservice.signedIn;
  }

  callApi() {
    this.dataFromAzureProtectedApi$ = this.httpClient
      .get('https://localhost:44390/weatherforecast')
      .pipe(catchError((error) => of(error)));
  }
  login() {
    this.authservice.signIn();
  }

  refreshSession() {
    this.authservice.forceRefreshSession().subscribe((result) => console.log(result));
  }

  logout() {
    this.authservice.signOut();
  }
}
