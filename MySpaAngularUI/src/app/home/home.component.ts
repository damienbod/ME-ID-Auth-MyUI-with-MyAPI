import { Component, OnInit } from '@angular/core';
import { Observable, of } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { AuthService } from '../auth.service';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-home',
  templateUrl: 'home.component.html',
})
export class HomeComponent implements OnInit {
  userData$: Observable<any>;
  dataFromAzureProtectedApi$: Observable<any>;
  isAuthenticated$: Observable<boolean>;
  constructor(
    private authservice: AuthService,
    private httpClient: HttpClient
  ) {}

  ngOnInit() {
    this.userData$ = this.authservice.userData;
    this.isAuthenticated$ = this.authservice.signedIn;

    this.dataFromAzureProtectedApi$ = this.httpClient
      .get('https://localhost:44390/weatherforecast')
      .pipe(catchError((error) => of(error)));
  }

  login() {
    this.authservice.signIn();
  }

  logout() {
    this.authservice.signOut();
  }
}
